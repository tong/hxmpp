package xmpp;

import xmpp.Stanza;

/**
	Acknowledges stanzas and resumes the stream after a disconnection.

	Enable stream management after resource binding:

	```haxe
	final sm = new StreamManagement(stream);
	Authentication.authenticate(stream, node, resource, password, mechanism, (?e) -> {
		if (e == null && StreamManagement.isOffered(stream.serverFeatures))
			sm.enable((?e) -> {});
	});
	```

	After a disconnection, restart the stream, authenticate without resource binding and resume the session.
	If resumption fails, bind a resource and enable stream management again:

	```haxe
	Authentication.saslAuthentication(stream, node, password, mechanism, (?e, features) -> {
		sm.resume((?e, ?unacked) -> {
			if (e != null)
				Authentication.bindResource(stream, resource, (?e, r) -> sm.enable((?e) -> {}));
		});
	});
	```

	- Sent stanzas are kept until the server acknowledged handling them (`onAck`), and resent on resumption.
	- Responses to iq requests sent before the disconnection are delivered after resumption.
	- After resumption do not request the roster or resend presence, the server retained this state.
	- Ending the stream (`Stream.end`) ends the session, it can not be resumed then.

	[XEP-0198: Stream Management](https://xmpp.org/extensions/xep-0198.html)
**/
@xep(198)
@:allow(xmpp.Stream)
class StreamManagement {
	public static inline var XMLNS = "urn:xmpp:sm:3";

	/** Sequence numbers wrap at 2^32 **/
	static inline var SEQ_MAX = 4294967296.0;

	/** Called for each sent stanza the server acknowledged handling **/
	public dynamic function onAck(stanza:XML) {}

	public final stream:Stream;

	/** Whether stanzas are counted on the current stream **/
	public var enabled(default, null) = false;

	/** The id of the session if it can be resumed, `null` otherwise **/
	public var id(default, null):Null<String>;

	/** The maximum resumption time in seconds preferred by the server, if announced **/
	public var max(default, null):Null<Int>;

	/** The location (`host:port`) preferred by the server for reconnecting, if announced **/
	public var location(default, null):Null<String>;

	/** Request an acknowledgement after sending stanzas, at most one pending request at a time **/
	public var requestAcks = true;

	/** Sent stanzas not yet acknowledged by the server **/
	public var unacked(get, never):Array<XML>;

	inline function get_unacked()
		return queue.copy();

	/** Number of handled received stanzas, counted once the server enabled or resumed the session **/
	var received = 0.0;

	var receiving = false;

	/** Number of sent stanzas the server acknowledged **/
	var acked = 0.0;

	/** Sent stanzas not yet acknowledged **/
	var queue:Array<XML> = [];

	var ackRequested = false;

	/** Address bound to the session, restored on resumption **/
	var jid:Null<String>;

	/** Pending iq requests of the disconnected stream, restored on resumption **/
	final suspendedQueries = new Map<String, Any>();

	var enableCallback:Null<(?error:Stanza.Error) -> Void>;
	var resumeCallback:Null<(?error:Stanza.Error, ?unacked:Array<XML>) -> Void>;

	public function new(stream:Stream) {
		this.stream = stream;
		stream.streamManagement = this;
	}

	/**
		Returns `true` if the stream features announce stream management.
	**/
	@:noUsing
	public static function isOffered(features:Null<XML>):Bool
		return features != null && features.elements.first(e -> e.name == "sm" && e.is(XMLNS)) != null;

	/**
		Enables stream management, after resource binding.

		Requests a resumable session if `resume`, with the preferred maximum resumption time `max` in seconds.
		Unacknowledged stanzas of a previous session are discarded.
	**/
	public function enable(resume = true, ?max:Int, callback:(?error:Stanza.Error) -> Void) {
		if (stream.serverFeatures != null && !isOffered(stream.serverFeatures)) {
			callback(new Stanza.Error(cancel, feature_not_implemented));
			return;
		}
		clear();
		jid = stream.jid;
		enableCallback = callback;
		final xml = XML.create("enable").set("xmlns", XMLNS);
		if (resume)
			xml.set("resume", "true");
		if (max != null)
			xml.set("max", Std.string(max));
		stream.send(xml);
		// the server counts stanzas received after <enable/>
		enabled = true;
	}

	/**
		Resumes the previous session, after authentication on a new stream (instead of resource binding).

		On success unacknowledged stanzas are resent.
		On failure the session is discarded and the stanzas the server did not handle are passed as `unacked`,
		e.g. to resend after enabling a new session.
	**/
	public function resume(callback:(?error:Stanza.Error, ?unacked:Array<XML>) -> Void) {
		if (id == null) {
			final unacked = queue;
			clear();
			callback(new Stanza.Error(cancel, item_not_found, "no resumable session"), unacked);
			return;
		}
		resumeCallback = callback;
		stream.send(XML.create("resume").set("xmlns", XMLNS).set("h", format(received)).set("previd", id));
	}

	/**
		Requests the server to acknowledge the handled stanzas.
	**/
	public function requestAck() {
		if (!enabled)
			return;
		ackRequested = true;
		stream.send(XML.create("r").set("xmlns", XMLNS));
	}

	/**
		Informs the server about the handled received stanzas, without being requested.
	**/
	public function sendAck() {
		if (receiving)
			stream.send(XML.create("a").set("xmlns", XMLNS).set("h", format(received)));
	}

	function handleSent(stanza:XML) {
		if (!enabled)
			return;
		queue.push(stanza);
		if (requestAcks && !ackRequested)
			requestAck();
	}

	function handleReceived() {
		if (receiving)
			received = (received + 1) % SEQ_MAX;
	}

	function handleNonza(xml:XML) {
		switch xml.name {
			case "r":
				sendAck();
			case "a" if (enabled):
				ackRequested = false;
				final h = parseSeq(xml.get("h"));
				if (h != null && handleAck(h) && requestAcks && queue.length > 0)
					requestAck();
			case "enabled" if (enableCallback != null):
				final callback = enableCallback;
				enableCallback = null;
				final resume = xml.get("resume");
				if (resume == "true" || resume == "1") {
					id = xml.get("id");
					location = xml.get("location");
				}
				max = Std.parseInt(xml.get("max"));
				receiving = true;
				callback();
			case "resumed" if (resumeCallback != null):
				final callback = resumeCallback;
				resumeCallback = null;
				if (!handleAck(parseSeq(xml.get("h")) ?? acked))
					return;
				final resend = queue;
				queue = [];
				stream.jid = jid;
				for (key => query in suspendedQueries)
					stream.queries.set(key, query);
				suspendedQueries.clear();
				enabled = receiving = true;
				ackRequested = false;
				for (stanza in resend)
					stream.send(stanza);
				callback();
			case "failed" if (enableCallback != null):
				final callback = enableCallback;
				clear();
				callback(Stanza.Error.fromXML(xml));
			case "failed" if (resumeCallback != null):
				final callback = resumeCallback;
				final h = parseSeq(xml.get("h"));
				if (h != null && !handleAck(h))
					return;
				final unacked = queue;
				clear();
				callback(Stanza.Error.fromXML(xml), unacked);
			case _:
		}
	}

	/**
		Removes the stanzas acknowledged by `h` from the queue.
		Ends the stream with an error if the server acknowledged more stanzas than were sent.
	**/
	function handleAck(h:Float):Bool {
		var count = h - acked;
		if (count < 0)
			count += SEQ_MAX;
		if (count > queue.length) {
			final sent = format((acked + queue.length) % SEQ_MAX);
			enabled = receiving = false;
			stream.output('<stream:error xmlns:stream="${Stream.XMLNS}"><undefined-condition xmlns="urn:ietf:params:xml:ns:xmpp-streams"/><handled-count-too-high xmlns="$XMLNS" h="${format(h)}" send-count="$sent"/></stream:error>');
			stream.end();
			return false;
		}
		acked = h;
		for (stanza in queue.splice(0, Std.int(count)))
			onAck(stanza);
		return true;
	}

	/** The stream is reset (disconnected or restarted) **/
	function handleReset(queries:Map<String, Any>) {
		if (id != null)
			for (key => query in queries)
				suspendedQueries.set(key, query);
		enabled = receiving = ackRequested = false;
		enableCallback = null;
		resumeCallback = null;
	}

	/** The stream is closed by the client, which ends the session **/
	function handleEnd() {
		sendAck();
		enabled = receiving = false;
		id = null;
		suspendedQueries.clear();
	}

	function clear() {
		enabled = receiving = ackRequested = false;
		enableCallback = null;
		resumeCallback = null;
		id = location = jid = null;
		max = null;
		received = acked = 0;
		queue = [];
		suspendedQueries.clear();
	}

	static function parseSeq(str:Null<String>):Null<Float> {
		if (str == null || !~/^[0-9]{1,10}$/.match(str))
			return null;
		final n = Std.parseFloat(str);
		return (n < SEQ_MAX) ? n : null;
	}

	static inline function format(n:Float):String
		return haxe.Int64.toStr(haxe.Int64.fromFloat(n));
}
