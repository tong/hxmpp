package xmpp;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import xmpp.IQ;

/**
	Action of a Jingle request.
**/
enum abstract JingleAction(String) from String to String {
	/** Accept a `content-add` action received from another party. **/
	var content_accept = "content-accept";

	/** Add one or more new content definitions to the session. **/
	var content_add = "content-add";

	/** Change the directionality of media sending. **/
	var content_modify = "content-modify";

	/** Reject a `content-add` action received from another party. **/
	var content_reject = "content-reject";

	/** Remove one or more content definitions from the session. **/
	var content_remove = "content-remove";

	/** Exchange information about parameters for an application type. **/
	var description_info = "description-info";

	/** Exchange information about security preconditions. **/
	var security_info = "security-info";

	/** Definitively accept a session negotiation. **/
	var session_accept = "session-accept";

	/** Send session-level information, such as a ping or (for Jingle RTP sessions) a ringing message. **/
	var session_info = "session-info";

	/** Request negotiation of a new Jingle session. **/
	var session_initiate = "session-initiate";

	/** End an existing session. **/
	var session_terminate = "session-terminate";

	/** Accept a `transport-replace` action received from another party. **/
	var transport_accept = "transport-accept";

	/** Exchange transport candidates. **/
	var transport_info = "transport-info";

	/** Reject a `transport-replace` action received from another party. **/
	var transport_reject = "transport-reject";

	/** Redefine a transport method or replace it with a different method. **/
	var transport_replace = "transport-replace";

	@:noCompletion public static function fromString(s:Null<String>):Null<JingleAction>
		return switch s {
			case "content-accept": content_accept;
			case "content-add": content_add;
			case "content-modify": content_modify;
			case "content-reject": content_reject;
			case "content-remove": content_remove;
			case "description-info": description_info;
			case "security-info": security_info;
			case "session-accept": session_accept;
			case "session-info": session_info;
			case "session-initiate": session_initiate;
			case "session-terminate": session_terminate;
			case "transport-accept": transport_accept;
			case "transport-info": transport_info;
			case "transport-reject": transport_reject;
			case "transport-replace": transport_replace;
			case _: null;
		}
}

/**
	Condition of a `<reason/>`, e.g. why a session was terminated.
**/
enum abstract JingleReason(String) from String to String {
	/** The party prefers to use an existing session with the peer (see `JingleReasonInfo.sid`). **/
	var alternative_session = "alternative-session";

	/** The party is busy and cannot accept a session. **/
	var busy;

	/** The initiator wishes to formally cancel the session initiation request. **/
	var cancel;

	/** The action is related to connectivity problems. **/
	var connectivity_error = "connectivity-error";

	/** The party wishes to formally decline the session. **/
	var decline;

	/** The session length has exceeded a pre-defined time limit. **/
	var expired;

	/** The party has been unable to initialize processing related to the application type. **/
	var failed_application = "failed-application";

	/** The party has been unable to establish connectivity for the transport method. **/
	var failed_transport = "failed-transport";

	/** The action is related to a non-specific application error. **/
	var general_error = "general-error";

	/** The entity is going offline or is no longer available. **/
	var gone;

	/** The party supports the offered application type but not the offered or negotiated parameters. **/
	var incompatible_parameters = "incompatible-parameters";

	/** The action is related to media processing problems. **/
	var media_error = "media-error";

	/** The action is related to a violation of local security policies. **/
	var security_error = "security-error";

	/** The normal course of state management, not an error. **/
	var success;

	/** A request has not been answered so the sender is timing out the request. **/
	var timeout;

	/** The party supports none of the offered application types. **/
	var unsupported_applications = "unsupported-applications";

	/** The party supports none of the offered transport methods. **/
	var unsupported_transports = "unsupported-transports";
}

/**
	The party that originally generated a content definition.
**/
enum abstract JingleCreator(String) from String to String {
	var initiator;
	var responder;
}

/**
	The parties sending media of a content definition.
**/
enum abstract JingleSenders(String) from String to String {
	var initiator;
	var responder;
	var both;
	var none;
}

/**
	State of a Jingle session.
**/
enum abstract JingleState(String) to String {
	/** Initiated, not yet accepted. **/
	var pending;

	/** Accepted. **/
	var active;

	/** Terminated. **/
	var ended;
}

/**
	A content definition: an application type (`description`) and a transport method (`transport`).
**/
typedef JingleContent = {
	var creator:JingleCreator;

	/** Unique name of the content (together with `creator`) **/
	var name:String;

	/** The parties sending media, `both` if not set **/
	var ?senders:JingleSenders;

	var ?disposition:String;

	/** `<description/>` of the application type, e.g. `JingleFileTransfer.createDescription` **/
	var ?description:XML;

	/** `<transport/>` of the transport method, e.g. `JingleIBB.createTransport` **/
	var ?transport:XML;

	/** `<security/>` precondition **/
	var ?security:XML;
}

/**
	A `<reason/>` of an action.
**/
typedef JingleReasonInfo = {
	var condition:JingleReason;

	/** Human-readable description **/
	var ?text:String;

	/** Session id of the alternative session (`alternative-session`) **/
	var ?sid:String;

	/** Application-specific elements **/
	var ?payload:Array<XML>;
}

/**
	A parsed `<jingle/>` element.
**/
typedef JingleRequest = {
	var action:JingleAction;
	var sid:String;
	var ?initiator:String;
	var ?responder:String;
	var contents:Array<JingleContent>;
	var ?reason:JingleReasonInfo;

	/** Other child elements (e.g. the payload of `session-info`) **/
	var info:Array<XML>;
}

/**
	Set up and manage peer-to-peer sessions (e.g. file transfers, voice and video calls) between XMPP entities.

	Jingle negotiates the session: each content combines an application type (`description`, e.g. a file)
	with a transport method (`transport`, e.g. in-band bytestreams). The media is exchanged by the transport.

		final jingle = new Jingle(stream);
		jingle.onSessionInitiate = session -> {
			// inspect session.contents, then session.accept(...) or session.terminate(decline)
		}
		final session = jingle.initiate('juliet@example.com/balcony', [content], res -> {});
		session.onAccept = contents -> {};
		session.onTerminate = reason -> {};

	Rules:
	- Sessions are identified by the peer and the session id; requests from other entities are answered
	  with `item-not-found` (`unknown-session`).
	- Every request is acknowledged before the session is accepted or terminated.
	- Advertise the supported application types and transports for service discovery
	  (e.g. `ServiceDiscovery.handleRequests(stream, identity, JingleFileTransfer.FEATURES)`).

	Not implemented: tie-breaking of simultaneous session requests, `transport-replace` negotiation.

	[XEP-0166: Jingle](https://xmpp.org/extensions/xep-0166.html)
**/
@xep(166)
class Jingle {
	public static inline var XMLNS = "urn:xmpp:jingle:1";
	public static inline var XMLNS_ERRORS = "urn:xmpp:jingle:errors:1";

	public final stream:Stream;

	/**
		Called with a new session requested by another entity (`pending`).
		Accept or terminate it; by default sessions are terminated with `unsupported-applications`.
	**/
	public dynamic function onSessionInitiate(session:JingleSession) {
		session.terminate(unsupported_applications);
	}

	/** Active and pending sessions **/
	final sessions = new Map<String, JingleSession>();

	/** Receivers of in-band bytestreams, by peer and bytestream session id **/
	@:allow(xmpp.JingleIBB) final ibbReceivers = new Map<String, Receiver>();

	/**
		Creates the session manager of `stream` and answers Jingle requests (and in-band bytestreams of Jingle sessions).
	**/
	public function new(stream:Stream) {
		this.stream = stream;
		stream.features.set(XMLNS, handleRequest);
		stream.features.set(JingleIBB.XMLNS_IBB, (iq, respond) -> JingleIBB.handleRequest(this, iq, respond));
	}

	/**
		Creates a new session with `peer` (a full jid), to be started with `session.initiate`
		once the session callbacks are set.
	**/
	public function createSession(peer:String, ?sid:String):JingleSession {
		final session = new JingleSession(this, sid ?? xmpp.Stream.makeRandomId(), peer, true);
		sessions.set(key(peer, session.sid), session);
		return session;
	}

	/**
		Request a new session with `peer` (a full jid) with `contents`, the response acknowledges the request.
		The session is accepted (`onAccept`) or terminated (`onTerminate`) by the peer.

		Set the callbacks before the response is received, or use `createSession` and `session.initiate`.
	**/
	public function initiate(peer:String, contents:Array<JingleContent>, ?sid:String, ?handler:Response<XML>->Void):JingleSession {
		final session = createSession(peer, sid);
		session.initiate(contents, handler);
		return session;
	}

	/**
		Returns the session `sid` with `peer`, or `null`.
	**/
	public function getSession(peer:String, sid:String):Null<JingleSession>
		return sessions.get(key(peer, sid));

	function handleRequest(iq:IQ, respond:Null<Response<XML>>->Void) {
		final xml = iq.payload;
		if (iq.type != Set || xml.name != "jingle" || iq.from == null) {
			respond(Response.failure(modify, bad_request));
			return;
		}
		final req = parse(xml);
		if (req == null) {
			respond(Response.failure(modify, bad_request));
			return;
		}
		final session = sessions.get(key(iq.from, req.sid));
		if (req.action == session_initiate) {
			if (session != null) {
				respond(jingleError(cancel, unexpected_request, "out-of-order"));
				return;
			}
			if (req.contents.length == 0) {
				respond(Response.failure(modify, bad_request));
				return;
			}
			final session = new JingleSession(this, req.sid, iq.from, false);
			session.contents = req.contents;
			sessions.set(key(iq.from, req.sid), session);
			respond(Response.success());
			onSessionInitiate(session);
			return;
		}
		if (session == null) {
			respond(jingleError(cancel, item_not_found, "unknown-session"));
			return;
		}
		switch req.action {
			case session_accept:
				if (!session.isInitiator || session.state != pending) {
					respond(jingleError(cancel, unexpected_request, "out-of-order"));
					return;
				}
				session.state = active;
				session.contents = req.contents;
				respond(Response.success());
				session.onAccept(req.contents);
			case session_terminate:
				respond(Response.success());
				session.end(req.reason ?? {condition: success});
			case session_info:
				if (req.info.length == 0 || session.onInfo(req.info))
					respond(Response.success());
				else
					respond(jingleError(modify, feature_not_implemented, "unsupported-info"));
			case _:
				session.onAction(req, (?error) -> respond((error == null) ? Response.success() : Response.fromError(error)));
		}
	}

	@:allow(xmpp.JingleSession)
	function removeSession(session:JingleSession)
		sessions.remove(key(session.peer, session.sid));

	@:allow(xmpp.JingleIBB)
	static function key(jid:String, sid:String):String
		return Jid.normalize(jid) + " " + sid;

	static function jingleError(type:xmpp.Stanza.ErrorType, condition:xmpp.Stanza.ErrorCondition, app:String):Response<XML>
		return Response.fromError(new xmpp.Stanza.Error(type, condition, null, {condition: app, xmlns: XMLNS_ERRORS}));

	/**
		Parses a `<jingle/>` element, returns `null` if the action or the session id is missing or invalid.
	**/
	@:noUsing
	public static function parse(xml:XML):Null<JingleRequest> {
		final action = JingleAction.fromString(xml.get("action"));
		final sid = xml.get("sid");
		if (action == null || sid == null || sid.length == 0)
			return null;
		final req:JingleRequest = {action: action, sid: sid, contents: [], info: []};
		if (xml.has("initiator"))
			req.initiator = xml.get("initiator");
		if (xml.has("responder"))
			req.responder = xml.get("responder");
		for (e in xml.elements) {
			switch e.name {
				case "content" if (e.ns == null || e.ns == XMLNS):
					req.contents.push(parseContent(e));
				case "reason" if (e.ns == null || e.ns == XMLNS):
					req.reason = parseReason(e);
				case _:
					req.info.push(e);
			}
		}
		return req;
	}

	/**
		Parses a `<content/>` element.
	**/
	@:noUsing
	public static function parseContent(xml:XML):JingleContent {
		final content:JingleContent = {creator: xml.get("creator") ?? JingleCreator.initiator, name: xml.get("name")};
		if (xml.has("senders"))
			content.senders = xml.get("senders");
		if (xml.has("disposition"))
			content.disposition = xml.get("disposition");
		for (e in xml.elements)
			switch e.name {
				case "description": content.description = e;
				case "transport": content.transport = e;
				case "security": content.security = e;
				case _:
			}
		return content;
	}

	/**
		Parses a `<reason/>` element.
	**/
	@:noUsing
	public static function parseReason(xml:XML):JingleReasonInfo {
		var reason:JingleReasonInfo = null;
		final payload = [];
		var text:String = null;
		for (e in xml.elements) {
			if (e.ns != null && e.ns != XMLNS) {
				payload.push(e);
				continue;
			}
			if (e.name == "text")
				text = e.text;
			else if (reason == null) {
				reason = {condition: e.name};
				if (e.name == alternative_session) {
					final sid = e.elements.named("sid")[0];
					if (sid != null)
						reason.sid = sid.text;
				}
			}
		}
		reason ??= {condition: general_error};
		if (text != null)
			reason.text = text;
		if (payload.length > 0)
			reason.payload = payload;
		return reason;
	}

	/**
		Creates a `<content/>` element.
	**/
	@:noUsing
	public static function createContent(content:JingleContent):XML {
		final xml = XML.create("content")
			.set("creator", content.creator)
			.set("name", content.name)
			.set("senders", content.senders)
			.set("disposition", content.disposition);
		if (content.description != null)
			xml.append(content.description);
		if (content.transport != null)
			xml.append(content.transport);
		if (content.security != null)
			xml.append(content.security);
		return xml;
	}

	/**
		Creates a `<reason/>` element.
	**/
	@:noUsing
	public static function createReason(reason:JingleReasonInfo):XML {
		final condition = XML.create(reason.condition);
		if (reason.condition == alternative_session && reason.sid != null)
			condition.append(XML.create("sid", reason.sid));
		final xml = XML.create("reason").append(condition);
		if (reason.text != null)
			xml.append(XML.create("text", reason.text));
		if (reason.payload != null)
			for (e in reason.payload)
				xml.append(e);
		return xml;
	}
}

/**
	A Jingle session with a peer, created by `Jingle.initiate` or received by `Jingle.onSessionInitiate`.
**/
@:allow(xmpp.Jingle)
@:allow(xmpp.JingleIBB)
@:allow(xmpp.JingleFileTransfer)
class JingleSession {
	public final jingle:Jingle;

	/** Session id **/
	public final sid:String;

	/** The other party (full jid) **/
	public final peer:String;

	/** `true` if this entity initiated the session **/
	public final isInitiator:Bool;

	public var state(default, null):JingleState = pending;

	/** The content definitions, as initiated and (once active) accepted **/
	public var contents(default, null):Array<JingleContent> = [];

	/** The reason of the termination, once `ended` **/
	public var reason(default, null):Null<JingleReasonInfo>;

	/** Called if the peer accepted the session, with the accepted contents. **/
	public dynamic function onAccept(contents:Array<JingleContent>) {}

	/**
		Called once the session ended, with the reason
		(`general-error` with the error condition as text if the session request failed).
	**/
	public dynamic function onTerminate(reason:JingleReasonInfo) {}

	/**
		Handle the informational payload of a `session-info` request, return `false` if not supported
		(answered with `feature-not-implemented`/`unsupported-info`). Pings (no payload) are always acknowledged.
	**/
	public dynamic function onInfo(payload:Array<XML>):Bool
		return false;

	/**
		Handle other actions (e.g. `transport-info`, `content-add`): call `respond` to acknowledge the request
		(before sending follow-up requests, e.g. `transport-accept`), or with an error.
		By default answered with `feature-not-implemented`.
	**/
	public dynamic function onAction(request:JingleRequest, respond:(?error:xmpp.Stanza.Error) -> Void)
		respond(new xmpp.Stanza.Error(cancel, feature_not_implemented));

	var initiated = false;

	function new(jingle:Jingle, sid:String, peer:String, isInitiator:Bool) {
		this.jingle = jingle;
		this.sid = sid;
		this.peer = peer;
		this.isInitiator = isInitiator;
	}

	/**
		Request the session (created by `Jingle.createSession`) with `contents`, the response acknowledges the request.
	**/
	public function initiate(contents:Array<JingleContent>, ?handler:Response<XML>->Void):Null<IQ> {
		if (!isInitiator || state != pending || initiated)
			return null;
		initiated = true;
		this.contents = contents;
		return send(session_initiate, contents, (res:Response<XML>) -> {
			if (!res.ok())
				end({condition: general_error, text: res.error.condition});
			if (handler != null)
				handler(res);
		});
	}

	/**
		Accept a session initiated by the peer with `contents` (by default the initiated contents).
	**/
	public function accept(?contents:Array<JingleContent>, ?handler:Response<XML>->Void):Null<IQ> {
		if (isInitiator || state != pending)
			return null;
		state = active;
		if (contents != null)
			this.contents = contents;
		return send(session_accept, this.contents, handler);
	}

	/**
		End the session, with `success` by default.
	**/
	public function terminate(condition:JingleReason = success, ?text:String, ?handler:Response<XML>->Void):Null<IQ> {
		if (state == ended)
			return null;
		final reason:JingleReasonInfo = {condition: condition};
		if (text != null)
			reason.text = text;
		// ended before sending: actions caused by the request (e.g. the peer closing a connection) are ignored
		state = ended;
		final iq = request(session_terminate, null, reason, null, handler);
		end(reason);
		return iq;
	}

	/**
		Send session-level information (e.g. `JingleFileTransfer.createReceived`); without payload a ping.
	**/
	public inline function info(?payload:Array<XML>, ?handler:Response<XML>->Void):Null<IQ>
		return send(session_info, null, null, payload, handler);

	/**
		Send a request with `action` in this session.
	**/
	public function send(action:JingleAction, ?contents:Array<JingleContent>, ?reason:JingleReasonInfo, ?payload:Array<XML>,
			?handler:Response<XML>->Void):Null<IQ>
		return (state == ended) ? null : request(action, contents, reason, payload, handler);

	function request(action:JingleAction, ?contents:Array<JingleContent>, ?reason:JingleReasonInfo, ?payload:Array<XML>,
			?handler:Response<XML>->Void):IQ {
		final xml = Payload.create(Jingle.XMLNS, "jingle").set("action", action).set("sid", sid);
		final own = jingle.stream.jid;
		if (action == session_initiate)
			xml.set("initiator", own);
		else if (action == session_accept)
			xml.set("responder", own);
		if (contents != null)
			for (c in contents)
				xml.append(Jingle.createContent(c));
		if (reason != null)
			xml.append(Jingle.createReason(reason));
		if (payload != null)
			for (e in payload)
				xml.append(e);
		return jingle.stream.set(xml, peer, handler ?? (res -> {}));
	}

	var finished = false;

	function end(reason:JingleReasonInfo) {
		if (finished)
			return;
		finished = true;
		state = ended;
		this.reason = reason;
		jingle.removeSession(this);
		onTerminate(reason);
	}
}

/**
	A file, as described in a file transfer.
**/
typedef JingleFile = {
	/** Name of the file, without directory **/
	var ?name:String;

	/** Last modified time ([XEP-0082](https://xmpp.org/extensions/xep-0082.html) date time) **/
	var ?date:String;

	/** Human-readable description **/
	var ?desc:String;

	/** Media type, `application/octet-stream` if not set **/
	var ?mediaType:String;

	/** Size in bytes **/
	var ?size:Float;

	/** Ranged transfers are supported, optionally of the range starting at `offset` with `length` **/
	var ?range:{?offset:Float, ?length:Float};

	/** Hashes of the file content **/
	var ?hashes:Array<Hash>;
}

/**
	A hash ([XEP-0300](https://xmpp.org/extensions/xep-0300.html)), e.g. `{algo: "sha-256", value: <base64>}`.
**/
typedef Hash = {
	var algo:String;

	/** Base64 encoded hash value **/
	var value:String;
}

/**
	Options of a file transfer.
**/
typedef JingleFileTransferOptions = {
	/** Block size of in-band bytestreams: offered by the sender, the maximum accepted by the receiver **/
	var ?blockSize:Int;

	/** Use SOCKS5 bytestreams (with this network configuration) **/
	var ?s5b:JingleS5BConfig;

	/** Fall back to in-band bytestreams if no SOCKS5 connection can be established (sender, default `true`) **/
	var ?fallback:Bool;

	/** Called with the number of sent or received bytes **/
	var ?onProgress:(bytes:Int) -> Void;
}

/**
	Transfer files with Jingle.

	Files are offered by the sender (`sendFile`) and transferred with SOCKS5 bytestreams (`JingleS5B`, direct or
	through a proxy) or in-band bytestreams (`JingleIBB`, the fallback).
	The receiver accepts (`receiveFile`) or declines (`session.terminate(decline)`) the offer,
	verifies the size and the hash of the received data and terminates the session (`success` or `media-error`).

		jingle.onSessionInitiate = session -> {
			final file = JingleFileTransfer.getFileOffer(session);
			if (file == null)
				return session.terminate(unsupported_applications);
			JingleFileTransfer.receiveFile(session, (reason, data) -> trace(reason.condition, data?.length));
		}
		JingleFileTransfer.sendFile(jingle, 'juliet@example.com/balcony', {name: 'test.txt'}, bytes, reason -> trace(reason.condition));

	With SOCKS5 bytestreams (e.g. on nodejs):

		final s5b:JingleS5BConfig = {network: new JingleS5BNodeNetwork()};
		JingleFileTransfer.sendFile(jingle, peer, file, bytes, {s5b: s5b}, reason -> trace(reason.condition));
		JingleFileTransfer.receiveFile(session, {s5b: s5b}, (reason, data) -> {});

	Not implemented: file requests (the receiver initiates), ranged transfers, multiple files per session.

	[XEP-0234: Jingle File Transfer](https://xmpp.org/extensions/xep-0234.html)
**/
@xep(234)
class JingleFileTransfer {
	public static inline var XMLNS = "urn:xmpp:jingle:apps:file-transfer:5";
	public static inline var XMLNS_HASHES = "urn:xmpp:hashes:2";

	/** Features to advertise for service discovery **/
	public static final FEATURES = [XMLNS, JingleIBB.XMLNS, JingleS5B.XMLNS];

	static inline var CONTENT_NAME = "a-file-offer";

	/**
		Offer `data` as `file` to `peer` (a full jid) and send it once accepted.

		The data is sent with SOCKS5 bytestreams if `options.s5b` is set (falling back to in-band bytestreams if no
		connection can be established), otherwise with in-band bytestreams.
		The `size` and a `sha-256` hash are added to `file` if not set.
		`callback` is called once the session ended, with the reason: `success` if the receiver confirmed the transfer.
	**/
	@:noUsing
	public static function sendFile(jingle:Jingle, peer:String, file:JingleFile, data:Bytes, ?options:JingleFileTransferOptions,
			callback:(reason:JingleReasonInfo) -> Void):JingleSession {
		final options:JingleFileTransferOptions = options ?? {};
		final blockSize = options.blockSize ?? JingleIBB.DEFAULT_BLOCK_SIZE;
		final file = Reflect.copy(file);
		file.size ??= data.length;
		if (file.hashes == null || file.hashes.length == 0)
			file.hashes = [hash(data)];
		final content:JingleContent = {
			creator: initiator,
			name: CONTENT_NAME,
			senders: initiator,
			description: createDescription(file)
		};
		final session = jingle.createSession(peer);
		var s5b:Null<JingleS5B> = null;
		var ibbSid:Null<String> = null;
		session.onTerminate = reason -> {
			if (s5b != null)
				s5b.close();
			callback(reason);
		}
		function sendIBB(sid:String, size:Int)
			JingleIBB.send(session, sid, size, data, options.onProgress, error -> {
				if (error != null)
					session.terminate(failed_transport, error.condition);
				// otherwise the receiver terminates the session after verifying the data
			});
		function fallback(reason:String) {
			if (session.state == ended)
				return;
			if (options.fallback == false) {
				session.terminate(connectivity_error, reason);
				return;
			}
			ibbSid = xmpp.Stream.makeRandomId();
			session.send(transport_replace, [{creator: initiator, name: CONTENT_NAME, transport: JingleIBB.createTransport(ibbSid, blockSize)}]);
		}
		session.onAction = (req, respond) -> {
			final c = req.contents.filter(c -> c.name == CONTENT_NAME)[0];
			final transport = (c == null) ? null : c.transport;
			switch req.action {
				case transport_info if (s5b != null && transport != null && transport.is(JingleS5B.XMLNS)):
					respond();
					s5b.handleInfo(transport);
				case transport_accept if (ibbSid != null):
					final ibb = JingleIBB.parseTransport(transport);
					if (ibb == null || ibb.sid != ibbSid) {
						respond(new xmpp.Stanza.Error(modify, bad_request));
						session.terminate(failed_transport);
						return;
					}
					respond();
					if (s5b != null)
						s5b.close();
					sendIBB(ibb.sid, Std.int(Math.min(blockSize, ibb.blockSize)));
				case transport_reject if (ibbSid != null):
					respond();
					session.terminate(failed_transport);
				case _:
					respond(new xmpp.Stanza.Error(cancel, feature_not_implemented));
			}
		}
		session.onAccept = contents -> {
			final accepted = contents.filter(c -> c.name == CONTENT_NAME)[0];
			final transport = (accepted == null) ? null : accepted.transport;
			if (s5b != null) {
				if (transport == null || !transport.is(JingleS5B.XMLNS)) {
					session.terminate(unsupported_transports);
					return;
				}
				s5b.onFailed = fallback;
				s5b.onReady = stream -> {
					var pos = 0;
					while (pos < data.length) {
						final len = Std.int(Math.min(65536, data.length - pos));
						stream.write(data.sub(pos, len));
						pos += len;
						if (options.onProgress != null)
							options.onProgress(pos);
					}
					// the receiver terminates the session after verifying the data
				}
				s5b.start(transport);
			} else {
				final ibb = JingleIBB.parseTransport(transport);
				if (ibb == null || ibb.sid != ibbSid) {
					session.terminate(unsupported_transports);
					return;
				}
				sendIBB(ibb.sid, Std.int(Math.min(blockSize, ibb.blockSize)));
			}
		};
		if (options.s5b != null) {
			s5b = new JingleS5B(session, CONTENT_NAME, initiator, options.s5b);
			s5b.prepare(null, () -> {
				content.transport = s5b.createTransport();
				session.initiate([content]);
			});
		} else {
			ibbSid = xmpp.Stream.makeRandomId();
			content.transport = JingleIBB.createTransport(ibbSid, blockSize);
			session.initiate([content]);
		}
		return session;
	}

	/**
		Returns the offered file of a session initiated by the peer, or `null` if the session is no file offer.
	**/
	@:noUsing
	public static function getFileOffer(session:JingleSession):Null<JingleFile> {
		final content = getFileContent(session);
		return (content == null) ? null : parseDescription(content.description);
	}

	/**
		Accept the file offer of `session` and receive the data.

		Offers with in-band bytestreams and SOCKS5 bytestreams are accepted; without `options.s5b`
		no SOCKS5 connection is attempted (the sender falls back to in-band bytestreams).
		`callback` is called once the session ended: with the reason `success` and the data if the transfer succeeded.
		The data is verified with the offered size and hashes (if supported, e.g. `sha-1` and `sha-256`).
	**/
	@:noUsing
	public static function receiveFile(session:JingleSession, ?options:JingleFileTransferOptions,
			callback:(reason:JingleReasonInfo, data:Null<Bytes>) -> Void) {
		final options:JingleFileTransferOptions = options ?? {};
		final maxBlockSize = options.blockSize ?? JingleIBB.MAX_BLOCK_SIZE;
		final content = getFileContent(session);
		final file = (content == null) ? null : parseDescription(content.description);
		var data:Null<Bytes> = null;
		var s5b:Null<JingleS5B> = null;
		session.onTerminate = reason -> {
			if (s5b != null)
				s5b.close();
			callback(reason, (reason.condition == success) ? data : null);
		}
		if (file == null) {
			session.terminate(unsupported_applications);
			return;
		}
		function complete(error:Null<xmpp.Stanza.Error>, received:Null<Bytes>) {
			if (session.state == ended)
				return;
			if (error != null) {
				session.terminate(failed_transport, error.condition);
				return;
			}
			if (file.size != null && received.length != file.size) {
				session.terminate(media_error, 'size mismatch');
				return;
			}
			if (file.hashes != null && verify(received, file.hashes) == false) {
				session.terminate(media_error, 'hash mismatch');
				return;
			}
			data = received;
			session.info([createReceived(content)]);
			session.terminate(success);
		}
		function accept(transport:XML)
			session.accept([
				{
					creator: content.creator,
					name: content.name,
					senders: content.senders,
					description: content.description,
					transport: transport
				}
			]);
		session.onAction = (req, respond) -> {
			final c = req.contents.filter(c -> c.name == content.name)[0];
			final transport = (c == null) ? null : c.transport;
			switch req.action {
				case transport_info if (s5b != null && transport != null && transport.is(JingleS5B.XMLNS)):
					respond();
					s5b.handleInfo(transport);
				case transport_replace if (transport != null):
					final ibb = JingleIBB.parseTransport(transport);
					respond();
					if (ibb == null) {
						session.send(transport_reject, [{creator: content.creator, name: content.name, transport: transport}]);
						return;
					}
					if (s5b != null)
						s5b.close();
					final blockSize = Std.int(Math.min(ibb.blockSize, maxBlockSize));
					JingleIBB.receive(session, ibb.sid, blockSize, file.size, options.onProgress, complete);
					session.send(transport_accept, [
						{creator: content.creator, name: content.name, transport: JingleIBB.createTransport(ibb.sid, blockSize)}
					]);
				case _:
					respond(new xmpp.Stanza.Error(cancel, feature_not_implemented));
			}
		}
		final transport = content.transport;
		final ibb = JingleIBB.parseTransport(transport);
		if (ibb != null) {
			final blockSize = Std.int(Math.min(ibb.blockSize, maxBlockSize));
			JingleIBB.receive(session, ibb.sid, blockSize, file.size, options.onProgress, complete);
			accept(JingleIBB.createTransport(ibb.sid, blockSize));
		} else if (transport != null && transport.is(JingleS5B.XMLNS) && transport.has("sid")) {
			s5b = new JingleS5B(session, content.name, content.creator, options.s5b, transport.get("sid"));
			s5b.onReady = stream -> {
				final buf = new BytesBuffer();
				var done = false;
				function finish(error:Null<xmpp.Stanza.Error>) {
					if (done)
						return;
					done = true;
					complete(error, (error == null) ? buf.getBytes() : null);
				}
				// without size the data is complete once the sender closes the connection
				stream.onClose = () -> finish((file.size == null) ? null : new xmpp.Stanza.Error(cancel, item_not_found, 'connection closed'));
				stream.onData = chunk -> {
					if (done)
						return;
					buf.add(chunk);
					if (options.onProgress != null)
						options.onProgress(buf.length);
					if (file.size != null && buf.length >= file.size)
						finish(null);
				}
			}
			// wait for the transport-replace (or the termination) of the sender
			s5b.onFailed = reason -> {};
			s5b.prepare(transport, () -> {
				accept(s5b.createTransport());
				s5b.start(transport);
			});
		} else {
			session.terminate(unsupported_transports);
		}
	}

	static function getFileContent(session:JingleSession):Null<JingleContent> {
		for (c in session.contents)
			if (c.description != null && c.description.is(XMLNS)) {
				// a file offer: the creator sends the file
				final offer = c.senders == (c.creator : String);
				return offer ? c : null;
			}
		return null;
	}

	/**
		Creates a file transfer `<description/>`.
	**/
	@:noUsing
	public static function createDescription(file:JingleFile):XML
		return XML.create("description").set("xmlns", XMLNS).append(createFile(file));

	/**
		Creates a `<file/>` element.
	**/
	@:noUsing
	public static function createFile(file:JingleFile):XML {
		final xml = XML.create("file");
		if (file.date != null)
			xml.append(XML.create("date", file.date));
		if (file.desc != null)
			xml.append(XML.create("desc", file.desc));
		if (file.mediaType != null)
			xml.append(XML.create("media-type", file.mediaType));
		if (file.name != null)
			xml.append(XML.create("name", file.name));
		if (file.range != null) {
			final range = XML.create("range");
			if (file.range.offset != null)
				range.set("offset", formatInt(file.range.offset));
			if (file.range.length != null)
				range.set("length", formatInt(file.range.length));
			xml.append(range);
		}
		if (file.size != null)
			xml.append(XML.create("size", formatInt(file.size)));
		if (file.hashes != null)
			for (h in file.hashes)
				xml.append(XML.create("hash", h.value).set("xmlns", XMLNS_HASHES).set("algo", h.algo));
		return xml;
	}

	/**
		Parses a file transfer `<description/>`, returns `null` if it has no `<file/>`.
	**/
	@:noUsing
	public static function parseDescription(xml:Null<XML>):Null<JingleFile> {
		if (xml == null || !xml.is(XMLNS))
			return null;
		final e = xml.elements.named("file")[0];
		return (e == null) ? null : parseFile(e);
	}

	/**
		Parses a `<file/>` element.
	**/
	@:noUsing
	public static function parseFile(xml:XML):JingleFile {
		final file:JingleFile = {};
		for (e in xml.elements) {
			final text:Null<String> = e.text;
			switch e.name {
				case "date": file.date = text;
				case "desc": file.desc = text;
				case "media-type": file.mediaType = text;
				case "name": file.name = text;
				case "size":
					final size = Std.parseFloat(text);
					if (!Math.isNaN(size))
						file.size = size;
				case "range":
					file.range = {};
					if (e.has("offset"))
						file.range.offset = Std.parseFloat(e.get("offset"));
					if (e.has("length"))
						file.range.length = Std.parseFloat(e.get("length"));
				case "hash" if (e.is(XMLNS_HASHES) && e.has("algo") && text != null):
					file.hashes ??= [];
					file.hashes.push({algo: e.get("algo"), value: StringTools.trim(text)});
				case _:
			}
		}
		return file;
	}

	/**
		Creates the `<received/>` payload of `session-info` confirming the receipt of a file.
	**/
	@:noUsing
	public static function createReceived(content:JingleContent):XML
		return XML.create("received").set("xmlns", XMLNS).set("creator", content.creator).set("name", content.name);

	/**
		Returns the hash of `data` (supported algorithms: `sha-1`, `sha-256`).
	**/
	@:noUsing
	public static function hash(data:Bytes, algo = "sha-256"):Hash {
		final digest = digest(data, algo);
		if (digest == null)
			throw 'unsupported hash algorithm: $algo';
		return {algo: algo, value: Base64.encode(digest)};
	}

	/**
		Returns `true` if `data` matches the `hashes` (all of the supported algorithms),
		`null` if none of the algorithms is supported.
	**/
	@:noUsing
	public static function verify(data:Bytes, hashes:Array<Hash>):Null<Bool> {
		var verified:Null<Bool> = null;
		for (h in hashes) {
			final digest = digest(data, h.algo);
			if (digest == null)
				continue;
			final value = try Base64.decode(h.value) catch (e) null;
			if (value == null || value.compare(digest) != 0)
				return false;
			verified = true;
		}
		return verified;
	}

	static function digest(data:Bytes, algo:String):Null<Bytes> {
		final name = switch algo {
			case "sha-1": "sha1";
			case "sha-256": "sha256";
			case _: return null;
		}
		// native implementations, the portable ones are too slow for files on these targets
		#if python
		return Bytes.ofData(python.Syntax.code("bytearray(__import__('hashlib').new({0}, {1}).digest())", name, data.getData()));
		#elseif nodejs
		return js.node.Crypto.createHash(name).update(js.node.Buffer.hxFromBytes(data)).digest().hxToBytes();
		#else
		return (name == "sha1") ? haxe.crypto.Sha1.make(data) : haxe.crypto.Sha256.make(data);
		#end
	}

	static function formatInt(v:Float):String
		return haxe.Int64.toStr(haxe.Int64.fromFloat(v));
}

/**
	Transport of Jingle sessions over in-band bytestreams: the data is sent in base64 encoded chunks in iq stanzas.
	Slow but works with every server and without network access between the peers.

	[XEP-0261: Jingle In-Band Bytestreams Transport Method](https://xmpp.org/extensions/xep-0261.html)
	[XEP-0047: In-Band Bytestreams](https://xmpp.org/extensions/xep-0047.html)
**/
@xep(261)
class JingleIBB {
	public static inline var XMLNS = "urn:xmpp:jingle:transports:ibb:1";
	public static inline var XMLNS_IBB = "http://jabber.org/protocol/ibb";

	/** Recommended block size (bytes before base64 encoding) **/
	public static inline var DEFAULT_BLOCK_SIZE = 4096;

	/** Maximum block size **/
	public static inline var MAX_BLOCK_SIZE = 65535;

	/**
		Creates a `<transport/>` element.
	**/
	@:noUsing
	public static function createTransport(sid:String, blockSize = DEFAULT_BLOCK_SIZE):XML
		return XML.create("transport").set("xmlns", XMLNS).set("sid", sid).set("block-size", Std.string(blockSize));

	/**
		Parses an in-band bytestream `<transport/>` element, returns `null` if it is none or invalid.
	**/
	@:noUsing
	public static function parseTransport(xml:Null<XML>):Null<{sid:String, blockSize:Int}> {
		if (xml == null || !xml.is(XMLNS) || !xml.has("sid"))
			return null;
		final blockSize = Std.parseInt(xml.get("block-size"));
		if (blockSize == null || blockSize <= 0 || blockSize > MAX_BLOCK_SIZE)
			return null;
		return {sid: xml.get("sid"), blockSize: blockSize};
	}

	/**
		Sends `data` to the peer of `session`: opens the bytestream `sid`, sends the chunks (each after the previous was
		acknowledged) and closes the bytestream. `callback` is called with `null` on success.
	**/
	public static function send(session:JingleSession, sid:String, blockSize:Int, data:Bytes, ?onProgress:(sent:Int) -> Void,
			callback:(error:Null<xmpp.Stanza.Error>) -> Void) {
		final stream = session.jingle.stream;
		final peer = session.peer;
		var pos = 0;
		var seq = 0;
		function next() {
			if (session.state == ended)
				return;
			if (pos >= data.length) {
				stream.set(XML.create("close").set("xmlns", XMLNS_IBB).set("sid", sid), peer, res -> callback(res.error));
				return;
			}
			final len = Std.int(Math.min(blockSize, data.length - pos));
			final chunk = XML.create("data", Base64.encode(data.sub(pos, len))).set("xmlns", XMLNS_IBB).set("sid", sid).set("seq", Std.string(seq));
			stream.set(chunk, peer, res -> {
				if (!res.ok()) {
					callback(res.error);
					return;
				}
				pos += len;
				seq = (seq + 1) & 0xFFFF;
				if (onProgress != null)
					onProgress(pos);
				next();
			});
		}
		stream.set(XML.create("open").set("xmlns", XMLNS_IBB).set("sid", sid).set("block-size", Std.string(blockSize)).set("stanza", "iq"), peer,
			res -> if (res.ok()) next() else callback(res.error));
	}

	/**
		Receives the bytestream `sid` from the peer of `session`, at most `maxSize` bytes if set.
		`callback` is called once the bytestream is closed with the received data, or with an error.
	**/
	public static function receive(session:JingleSession, sid:String, blockSize:Int, ?maxSize:Float, ?onProgress:(received:Int) -> Void,
			callback:(error:Null<xmpp.Stanza.Error>, data:Null<Bytes>) -> Void) {
		final jingle = session.jingle;
		final key = Jingle.key(session.peer, sid);
		jingle.ibbReceivers.set(key, new Receiver(session, blockSize, maxSize, onProgress, (error, data) -> {
			jingle.ibbReceivers.remove(key);
			callback(error, data);
		}));
	}

	@:allow(xmpp.Jingle)
	static function handleRequest(jingle:Jingle, iq:IQ, respond:Null<Response<XML>>->Void) {
		final xml = iq.payload;
		final receiver = (iq.from == null || !xml.has("sid")) ? null : jingle.ibbReceivers.get(Jingle.key(iq.from, xml.get("sid")));
		if (iq.type != Set) {
			respond(Response.failure(modify, bad_request));
			return;
		}
		if (receiver == null || receiver.session.state == ended) {
			respond(Response.failure(cancel, item_not_found));
			return;
		}
		respond(receiver.handle(xml));
	}
}

@:allow(xmpp.JingleIBB)
private class Receiver {
	final session:JingleSession;
	final blockSize:Int;
	final maxSize:Null<Float>;
	final onProgress:Null<(received:Int) -> Void>;
	final callback:(error:Null<xmpp.Stanza.Error>, data:Null<Bytes>) -> Void;
	final buf = new BytesBuffer();
	var opened = false;
	var seq = 0;

	function new(session, blockSize, maxSize, onProgress, callback) {
		this.session = session;
		this.blockSize = blockSize;
		this.maxSize = maxSize;
		this.onProgress = onProgress;
		this.callback = callback;
	}

	function handle(xml:XML):Response<XML> {
		switch xml.name {
			case "open":
				final size = Std.parseInt(xml.get("block-size"));
				if (opened || size == null || size <= 0)
					return Response.failure(cancel, not_acceptable);
				if (size > blockSize)
					return Response.failure(modify, resource_constraint);
				if (xml.has("stanza") && xml.get("stanza") != "iq")
					return Response.failure(cancel, feature_not_implemented);
				opened = true;
				return Response.success();
			case "data" if (opened):
				if (Std.parseInt(xml.get("seq")) != seq)
					return fail(new xmpp.Stanza.Error(cancel, unexpected_request, 'unexpected sequence number'));
				final text:Null<String> = xml.text;
				final chunk = try Base64.decode(~/\s+/g.replace(text ?? "", "")) catch (e) null;
				if (chunk == null || chunk.length > blockSize)
					return fail(new xmpp.Stanza.Error(modify, bad_request));
				if (maxSize != null && buf.length + chunk.length > maxSize)
					return fail(new xmpp.Stanza.Error(cancel, not_acceptable, 'more data than announced'));
				buf.add(chunk);
				seq = (seq + 1) & 0xFFFF;
				if (onProgress != null)
					onProgress(buf.length);
				return Response.success();
			case "close" if (opened):
				opened = false;
				callback(null, buf.getBytes());
				return Response.success();
			case _:
				return Response.failure(cancel, item_not_found);
		}
	}

	function fail(error:xmpp.Stanza.Error):Response<XML> {
		opened = false;
		callback(error, null);
		return Response.fromError(error);
	}
}

/**
	Type of a SOCKS5 bytestream candidate.
**/
enum abstract JingleS5BCandidateType(String) from String to String {
	/** Direct connection using the given interface **/
	var direct;

	/** Direct connection using NAT assisting technologies like NAT-PMP or UPnP-IGD **/
	var assisted;

	/** Tunnel protocols such as Teredo **/
	var tunnel;

	/** SOCKS5 relay **/
	var proxy;
}

/**
	A host offered for a SOCKS5 bytestream.
**/
typedef JingleS5BCandidate = {
	/** Candidate id **/
	var cid:String;

	var host:String;

	/** The entity hosting the candidate (the offering party, or the proxy) **/
	var jid:String;

	var port:Int;
	var priority:Int;
	var type:JingleS5BCandidateType;
}

/**
	A SOCKS5 bytestreams proxy ([XEP-0065](https://xmpp.org/extensions/xep-0065.html) streamhost).
**/
typedef JingleS5BStreamhost = {
	var jid:String;
	var host:String;
	var port:Int;
}

/**
	A parsed SOCKS5 bytestreams `<transport/>` element.
**/
typedef JingleS5BTransportInfo = {
	var sid:String;
	var ?dstaddr:String;
	var ?mode:String;
	var candidates:Array<JingleS5BCandidate>;

	/** `transport-info`: the candidate the peer connected to **/
	var ?candidateUsed:String;

	/** `transport-info`: the peer could not connect to any candidate **/
	var candidateError:Bool;

	/** `transport-info`: the proxy candidate has been activated **/
	var ?activated:String;

	/** `transport-info`: the peer could not connect to the proxy **/
	var proxyError:Bool;
}

/**
	Network configuration of SOCKS5 bytestreams.
**/
typedef JingleS5BConfig = {
	/** Network access, e.g. `JingleS5BNodeNetwork` on nodejs; without network only in-band bytestreams can be used **/
	var ?network:JingleS5BNetwork;

	/** Offer direct connections (listen for connections of the peer), default `true` **/
	var ?direct:Bool;

	/** Addresses offered for direct connections, by default `network.addresses()` **/
	var ?hosts:Array<String>;

	/** SOCKS5 proxies to offer (see `JingleS5B.requestStreamhost`) **/
	var ?proxies:Array<JingleS5BStreamhost>;
}

/**
	Network access for SOCKS5 bytestreams.
**/
interface JingleS5BNetwork {
	/** Opens a TCP connection, `callback` is called with an error or the connection **/
	function connect(host:String, port:Int, callback:(error:Null<String>, connection:Null<JingleS5BConnection>) -> Void):Void;

	/**
		Listens for TCP connections on all interfaces on a free port, `callback` is called with an error or the port.
		Returns a function to stop listening.
	**/
	function listen(onConnection:JingleS5BConnection->Void, callback:(error:Null<String>, port:Int) -> Void):() -> Void;

	/** Returns the addresses of the local interfaces (offered for direct connections) **/
	function addresses():Array<String>;
}

/**
	A TCP connection.
**/
interface JingleS5BConnection {
	/** Called with received data **/
	var onData:Bytes->Void;

	/** Called once the connection is closed **/
	var onClose:() -> Void;

	function write(data:Bytes):Void;
	function close():Void;
}

/**
	An established SOCKS5 bytestream. Data received before `onData` is set is buffered.

	Set `onClose` before `onData`.
**/
class JingleS5BStream {
	/** Called once the connection is closed (after all data has been passed to `onData`) **/
	public dynamic function onClose() {}

	/** Called with received data **/
	public var onData(default, set):Null<Bytes->Void>;

	public var closed(default, null) = false;

	final connection:JingleS5BConnection;
	var buffer:Null<BytesBuffer>;

	@:allow(xmpp.JingleS5B)
	function new(connection:JingleS5BConnection, ?pending:Bytes) {
		this.connection = connection;
		if (pending != null && pending.length > 0) {
			buffer = new BytesBuffer();
			buffer.add(pending);
		}
		connection.onData = data -> {
			if (onData != null)
				onData(data);
			else {
				buffer ??= new BytesBuffer();
				buffer.add(data);
			}
		}
		connection.onClose = () -> {
			if (closed)
				return;
			closed = true;
			if (onData != null)
				onClose();
		}
	}

	function set_onData(f:Null<Bytes->Void>) {
		onData = f;
		if (f != null && buffer != null) {
			final data = buffer.getBytes();
			buffer = null;
			if (data.length > 0)
				f(data);
		}
		if (f != null && closed)
			onClose();
		return f;
	}

	public inline function write(data:Bytes)
		if (!closed)
			connection.write(data);

	public function close() {
		if (closed)
			return;
		closed = true;
		connection.close();
	}
}

/**
	Transport of Jingle sessions over SOCKS5 bytestreams: a direct TCP connection between the peers,
	or a connection through a SOCKS5 proxy.

	Both parties offer candidates (their own addresses and proxies), try to connect to the candidates of the peer
	(in order of priority) and report the result (`candidate-used` or `candidate-error`).
	The nominated candidate is the used candidate with the highest priority (on equal priority the initiator's choice).
	If no connection could be established, the initiator falls back to another transport (`transport-replace`).

	Rules:
	- Candidates expose IP addresses: offer them only to entities the user approved (e.g. by accepting the session).
	- The connection is not encrypted.

	[XEP-0260: Jingle SOCKS5 Bytestreams Transport Method](https://xmpp.org/extensions/xep-0260.html)
	[XEP-0065: SOCKS5 Bytestreams](https://xmpp.org/extensions/xep-0065.html)
**/
@xep(260)
class JingleS5B {
	public static inline var XMLNS = "urn:xmpp:jingle:transports:s5b:1";
	public static inline var XMLNS_BYTESTREAMS = "http://jabber.org/protocol/bytestreams";

	/** Called with the established bytestream **/
	public dynamic function onReady(stream:JingleS5BStream) {}

	/** Called if no bytestream could be established **/
	public dynamic function onFailed(reason:String) {}

	public final session:JingleSession;

	/** Bytestream session id **/
	public final sid:String;

	/** Candidates offered by this entity **/
	public var candidates(default, null):Array<JingleS5BCandidate> = [];

	/** Candidates offered by the peer **/
	public var remoteCandidates(default, null):Array<JingleS5BCandidate> = [];

	/** The nominated candidate, once negotiated **/
	public var nominated(default, null):Null<JingleS5BCandidate>;

	final contentName:String;
	final creator:JingleCreator;
	final config:JingleS5BConfig;
	final network:Null<JingleS5BNetwork>;
	final incoming = new Array<JingleS5BStream>();
	var stopListening:Null<() -> Void>;
	var remoteDstaddr:Null<String>;

	/** Result of the connection attempts to the peer's candidates **/
	var local:Null<{candidate:JingleS5BCandidate, stream:JingleS5BStream}>;

	var localDone = false;

	/** The cid of the own candidate the peer connected to **/
	var remoteUsed:Null<String>;

	var remoteDone = false;
	var activated:Null<String>;
	var awaitActivation:Null<String>;
	var stream:Null<JingleS5BStream>;
	var finished = false;
	var closed = false;

	/**
		Creates the transport of the content `contentName` of `session`; `sid` is the bytestream session id
		(the responder uses the one of the initiator's transport).
	**/
	public function new(session:JingleSession, contentName:String, creator:JingleCreator, ?config:JingleS5BConfig, ?sid:String) {
		this.session = session;
		this.contentName = contentName;
		this.creator = creator;
		this.config = config ?? {};
		this.network = this.config.network;
		this.sid = sid ?? xmpp.Stream.makeRandomId();
	}

	var ownJid(get, never):String;

	inline function get_ownJid():String
		return session.jingle.stream.jid ?? "";

	/** DST.ADDR of the own candidates: SHA1(sid + own jid + peer jid) **/
	public var dstaddr(get, never):String;

	inline function get_dstaddr():String
		return createDstaddr(sid, ownJid, session.peer);

	/**
		Gathers the own candidates (listens for direct connections), then calls `callback`.
		`remote` (the transport of the initiator) excludes candidates already offered by the peer.
	**/
	public function prepare(?remote:XML, callback:() -> Void) {
		final info = (remote == null) ? null : parseTransport(remote);
		final offered = (info == null) ? [] : [for (c in info.candidates) c.host + ":" + c.port];
		function add(c:JingleS5BCandidate)
			if (!offered.contains(c.host + ":" + c.port))
				candidates.push(c);
		function addProxies() {
			if (config.proxies != null)
				for (i => p in config.proxies)
					add({
						cid: xmpp.Stream.makeRandomId(8),
						host: p.host,
						jid: p.jid,
						port: p.port,
						priority: priority(proxy, 65535 - i),
						type: proxy
					});
			callback();
		}
		if (network == null || config.direct == false) {
			addProxies();
			return;
		}
		stopListening = network.listen(handleConnection, (error, port) -> {
			if (closed)
				return;
			if (error == null) {
				final hosts = config.hosts ?? network.addresses();
				for (i => host in hosts)
					add({
						cid: xmpp.Stream.makeRandomId(8),
						host: host,
						jid: ownJid,
						port: port,
						priority: priority(direct, 65535 - i),
						type: direct
					});
			}
			addProxies();
		});
	}

	/**
		Returns the own `<transport/>` with the candidates.
	**/
	public function createTransport():XML {
		final xml = XML.create("transport").set("xmlns", XMLNS).set("sid", sid);
		if (session.isInitiator)
			xml.set("mode", "tcp");
		if (candidates.filter(c -> c.type == proxy).length > 0)
			xml.set("dstaddr", dstaddr);
		for (c in candidates)
			xml.append(createCandidate(c));
		return xml;
	}

	/**
		Starts connecting to the candidates of the peer's `transport`.
	**/
	public function start(transport:XML) {
		final info = parseTransport(transport);
		if (info == null || info.sid != sid) {
			fail("invalid transport");
			return;
		}
		remoteCandidates = info.candidates.copy();
		remoteCandidates.sort((a, b) -> b.priority - a.priority);
		remoteDstaddr = info.dstaddr ?? createDstaddr(sid, session.peer, ownJid);
		tryCandidate(0);
	}

	/**
		Handles a `<transport/>` of a `transport-info` request.
	**/
	public function handleInfo(transport:XML) {
		final info = parseTransport(transport);
		if (info == null || info.sid != sid || closed)
			return;
		if (info.candidateUsed != null && !remoteDone) {
			remoteDone = true;
			remoteUsed = info.candidateUsed;
			nominate();
		} else if (info.candidateError && !remoteDone) {
			remoteDone = true;
			nominate();
		} else if (info.activated != null) {
			activated = info.activated;
			if (awaitActivation == info.activated)
				ready(local.stream);
		} else if (info.proxyError) {
			fail("proxy-error");
		}
	}

	/**
		Closes all connections.
	**/
	public function close() {
		if (closed)
			return;
		closed = true;
		finished = true;
		if (stopListening != null)
			stopListening();
		for (s in incoming)
			s.close();
		if (local != null)
			local.stream.close();
		if (stream != null)
			stream.close();
	}

	function tryCandidate(i:Int) {
		if (closed || localDone)
			return;
		final c = remoteCandidates[i];
		final used = (remoteUsed == null) ? null : candidates.filter(c -> c.cid == remoteUsed)[0];
		if (c == null || network == null || (used != null && c.priority < used.priority)) {
			// no candidate left, or only candidates with a lower priority than the one used by the peer
			localDone = true;
			sendInfo(XML.create("candidate-error"));
			nominate();
			return;
		}
		network.connect(c.host, c.port, (error, connection) -> {
			if (closed) {
				if (connection != null)
					connection.close();
				return;
			}
			if (error != null) {
				tryCandidate(i + 1);
				return;
			}
			socks5Connect(connection, remoteDstaddr, (error, stream) -> {
				if (closed || localDone) {
					if (stream != null)
						stream.close();
					return;
				}
				if (error != null) {
					connection.close();
					tryCandidate(i + 1);
					return;
				}
				localDone = true;
				local = {candidate: c, stream: stream};
				sendInfo(XML.create("candidate-used").set("cid", c.cid));
				nominate();
			});
		});
	}

	function handleConnection(connection:JingleS5BConnection) {
		if (closed || finished) {
			connection.close();
			return;
		}
		socks5Accept(connection, addr -> addr == dstaddr, (error, addr, stream) -> {
			if (error == null) {
				if (closed || finished)
					stream.close();
				else
					incoming.push(stream);
			}
		});
	}

	function nominate() {
		if (finished || !localDone || !remoteDone)
			return;
		final ours = (local == null) ? null : local.candidate;
		final theirs = (remoteUsed == null) ? null : candidates.filter(c -> c.cid == remoteUsed)[0];
		if (ours == null && theirs == null) {
			fail("no candidate");
			return;
		}
		// the candidate this entity connected to, unless the peer's has a higher priority (on equal priority: the initiator's choice)
		final useOurs = (theirs == null) || (ours != null
			&& (ours.priority > theirs.priority || (ours.priority == theirs.priority && session.isInitiator)));
		finished = true;
		if (stopListening != null) {
			stopListening();
			stopListening = null;
		}
		if (useOurs) {
			nominated = ours;
			for (s in incoming)
				s.close();
			if (ours.type == proxy) {
				// the peer activates its proxy
				awaitActivation = ours.cid;
				if (activated == ours.cid)
					ready(local.stream);
			} else
				ready(local.stream);
		} else {
			nominated = theirs;
			if (local != null)
				local.stream.close();
			if (theirs.type == proxy) {
				for (s in incoming)
					s.close();
				activateProxy(theirs);
			} else {
				final open = incoming.filter(s -> !s.closed);
				if (open.length == 0) {
					fail("no connection");
					return;
				}
				for (s in open.slice(1))
					s.close();
				ready(open[0]);
			}
		}
	}

	function activateProxy(c:JingleS5BCandidate) {
		function proxyError(reason:String) {
			sendInfo(XML.create("proxy-error"));
			fail(reason);
		}
		if (network == null) {
			proxyError("no network");
			return;
		}
		network.connect(c.host, c.port, (error, connection) -> {
			if (closed) {
				if (connection != null)
					connection.close();
				return;
			}
			if (error != null) {
				proxyError(error);
				return;
			}
			socks5Connect(connection, dstaddr, (error, stream) -> {
				if (error != null) {
					connection.close();
					proxyError(error);
					return;
				}
				this.stream = stream;
				activate(session.jingle.stream, c.jid, sid, session.peer, res -> {
					if (closed)
						return;
					if (!res.ok()) {
						proxyError(res.error.condition);
						return;
					}
					sendInfo(XML.create("activated").set("cid", c.cid));
					ready(stream);
				});
			});
		});
	}

	function ready(stream:JingleS5BStream) {
		if (closed)
			return;
		this.stream = stream;
		awaitActivation = null;
		onReady(stream);
	}

	function fail(reason:String) {
		if (closed)
			return;
		close();
		onFailed(reason);
	}

	function sendInfo(e:XML)
		session.send(transport_info, [
			{
				creator: creator,
				name: contentName,
				transport: XML.create("transport").set("xmlns", XMLNS).set("sid", sid).append(e)
			}
		]);

	/**
		Returns the priority of a candidate: `(2^16) * type preference + local preference` (0-65535).
	**/
	@:noUsing
	public static function priority(type:JingleS5BCandidateType, localPreference = 0):Int {
		final preference = switch type {
			case direct: 126;
			case assisted: 120;
			case tunnel: 110;
			case proxy: 10;
			case _: 0;
		}
		return (preference << 16) + localPreference;
	}

	/**
		Returns the SOCKS5 DST.ADDR of a bytestream: the hex SHA1 of `sid + requester + target`.
	**/
	@:noUsing
	public static inline function createDstaddr(sid:String, requester:String, target:String):String
		return haxe.crypto.Sha1.encode(sid + requester + target);

	/**
		Creates a `<candidate/>` element.
	**/
	@:noUsing
	public static function createCandidate(c:JingleS5BCandidate):XML
		return XML.create("candidate")
			.set("cid", c.cid)
			.set("host", c.host)
			.set("jid", c.jid)
			.set("port", Std.string(c.port))
			.set("priority", Std.string(c.priority))
			.set("type", c.type);

	/**
		Parses a SOCKS5 bytestreams `<transport/>` element, returns `null` if it is none.
	**/
	@:noUsing
	public static function parseTransport(xml:Null<XML>):Null<JingleS5BTransportInfo> {
		if (xml == null || !xml.is(XMLNS) || !xml.has("sid"))
			return null;
		final info:JingleS5BTransportInfo = {
			sid: xml.get("sid"),
			candidates: [],
			candidateError: false,
			proxyError: false
		};
		if (xml.has("dstaddr"))
			info.dstaddr = xml.get("dstaddr");
		if (xml.has("mode"))
			info.mode = xml.get("mode");
		for (e in xml.elements) {
			switch e.name {
				case "candidate":
					final port = Std.parseInt(e.get("port"));
					final priority = Std.parseInt(e.get("priority"));
					if (!e.has("cid") || !e.has("host") || !e.has("jid") || port == null || priority == null)
						continue;
					info.candidates.push({
						cid: e.get("cid"),
						host: e.get("host"),
						jid: e.get("jid"),
						port: port,
						priority: priority,
						type: e.get("type") ?? direct
					});
				case "candidate-used" if (e.has("cid")):
					info.candidateUsed = e.get("cid");
				case "candidate-error":
					info.candidateError = true;
				case "activated" if (e.has("cid")):
					info.activated = e.get("cid");
				case "proxy-error":
					info.proxyError = true;
				case _:
			}
		}
		return info;
	}

	/**
		Requests the network address of the SOCKS5 bytestreams proxy `jid` (e.g. `proxy.example.com`),
		use `parseStreamhost` to read the result.
	**/
	public static inline function requestStreamhost(stream:Stream, jid:String, handler:Response<XML>->Void):IQ
		return stream.get(Payload.create(XMLNS_BYTESTREAMS), jid, handler);

	/**
		Parses the `<streamhost/>` of a proxy query result.
	**/
	@:noUsing
	public static function parseStreamhost(payload:Null<XML>):Null<JingleS5BStreamhost> {
		if (payload == null)
			return null;
		final e = payload.elements.named("streamhost")[0];
		if (e == null || !e.has("jid") || !e.has("host"))
			return null;
		final port = Std.parseInt(e.get("port")) ?? 1080;
		return {jid: e.get("jid"), host: e.get("host"), port: port};
	}

	/**
		Activates the bytestream `sid` at the proxy `jid` to `target`.
	**/
	public static inline function activate(stream:Stream, jid:String, sid:String, target:String, handler:Response<XML>->Void):IQ
		return stream.set(Payload.create(XMLNS_BYTESTREAMS).set("sid", sid).append(XML.create("activate", target)), jid, handler);

	/**
		Performs the SOCKS5 handshake (client) on `connection`, requesting `dstaddr`.
		`callback` is called with an error, or the bytestream.
	**/
	@:noUsing
	public static function socks5Connect(connection:JingleS5BConnection, dstaddr:String,
			callback:(error:Null<String>, stream:Null<JingleS5BStream>) -> Void) {
		final reader = new Socks5Reader(connection);
		var state = 0;
		var done = false;
		function finish(error:Null<String>) {
			if (done)
				return;
			done = true;
			reader.detach();
			callback(error, (error == null) ? new JingleS5BStream(connection, reader.remaining()) : null);
		}
		connection.onClose = () -> finish("connection closed");
		reader.process = () -> {
			switch state {
				case 0:
					final r = reader.read(2);
					if (r == null)
						return false;
					if (r.get(0) != 5 || r.get(1) != 0) {
						finish("authentication method not accepted");
						return false;
					}
					state = 1;
					connection.write(socks5Request(1, dstaddr));
					return true;
				case 1:
					final reply = reader.readMessage();
					if (reply == null)
						return false;
					if (reply.code != 0) {
						finish('connection refused (${reply.code})');
						return false;
					}
					state = 2;
					finish(null);
					return false;
				case _:
					return false;
			}
		}
		connection.write(Bytes.ofHex("050100"));
	}

	/**
		Performs the SOCKS5 handshake (server) on `connection`: accepts connect requests to an address for which `check` returns `true`.
		`callback` is called with an error, or the requested address and the bytestream.
	**/
	@:noUsing
	public static function socks5Accept(connection:JingleS5BConnection, check:String->Bool,
			callback:(error:Null<String>, dstaddr:Null<String>, stream:Null<JingleS5BStream>) -> Void) {
		final reader = new Socks5Reader(connection);
		var state = 0;
		var done = false;
		function finish(error:Null<String>, ?addr:String) {
			if (done)
				return;
			done = true;
			reader.detach();
			if (error != null)
				connection.close();
			callback(error, addr, (error == null) ? new JingleS5BStream(connection, reader.remaining()) : null);
		}
		connection.onClose = () -> finish("connection closed");
		reader.process = () -> {
			switch state {
				case 0:
					final header = reader.peek(2);
					if (header == null)
						return false;
					final methods = reader.read(2 + header.get(1));
					if (methods == null)
						return false;
					var noAuth = false;
					for (i in 2...methods.length)
						if (methods.get(i) == 0)
							noAuth = true;
					if (methods.get(0) != 5 || !noAuth) {
						connection.write(Bytes.ofHex("05ff"));
						finish("no acceptable authentication method");
						return false;
					}
					state = 1;
					connection.write(Bytes.ofHex("0500"));
					return true;
				case 1:
					final request = reader.readMessage();
					if (request == null)
						return false;
					state = 2;
					if (request.code != 1 || request.address == null || !check(request.address)) {
						// command not supported / connection refused
						connection.write(socks5Request(request.code != 1 ? 7 : 5, request.address ?? ""));
						finish("connection refused");
						return false;
					}
					// the bytestream is set up before the client is informed (and may use it)
					finish(null, request.address);
					connection.write(socks5Request(0, request.address));
					return false;
				case _:
					return false;
			}
		}
	}

	/** A SOCKS5 request (code: command) or reply (code: status) with a domain name address and port 0 **/
	static function socks5Request(code:Int, address:String):Bytes {
		final addr = Bytes.ofString(address);
		final b = new BytesBuffer();
		b.addByte(5);
		b.addByte(code);
		b.addByte(0);
		b.addByte(3);
		b.addByte(addr.length);
		b.add(addr);
		b.addByte(0);
		b.addByte(0);
		return b.getBytes();
	}
}

/**
	Reads the messages of a SOCKS5 handshake from a connection.
**/
private class Socks5Reader {
	public var process:() -> Bool = () -> false;

	final connection:JingleS5BConnection;
	var buffer = Bytes.alloc(0);
	var processing = false;
	var detached = false;

	public function new(connection:JingleS5BConnection) {
		this.connection = connection;
		connection.onData = data -> {
			final b = Bytes.alloc(buffer.length + data.length);
			b.blit(0, buffer, 0, buffer.length);
			b.blit(buffer.length, data, 0, data.length);
			buffer = b;
			if (processing)
				return; // re-entrant call, processed by the running loop
			processing = true;
			while (!detached && process()) {}
			processing = false;
		}
	}

	public function peek(n:Int):Null<Bytes>
		return (buffer.length < n) ? null : buffer.sub(0, n);

	public function read(n:Int):Null<Bytes> {
		if (buffer.length < n)
			return null;
		final r = buffer.sub(0, n);
		buffer = buffer.sub(n, buffer.length - n);
		return r;
	}

	/** Reads a request or reply: VER CODE RSV ATYP ADDR PORT **/
	public function readMessage():Null<{code:Int, address:Null<String>}> {
		if (buffer.length < 5)
			return null;
		final atyp = buffer.get(3);
		final addrLength = switch atyp {
			case 1: 4;
			case 3: 1 + buffer.get(4);
			case 4: 16;
			case _: 0;
		}
		final m = read(4 + addrLength + 2);
		if (m == null)
			return null;
		return {code: m.get(1), address: (atyp == 3) ? m.getString(5, addrLength - 1) : null};
	}

	public function remaining():Bytes {
		final r = buffer;
		buffer = Bytes.alloc(0);
		return r;
	}

	public function detach()
		detached = true;
}

#if nodejs
/**
	Network access for SOCKS5 bytestreams on nodejs.
**/
class JingleS5BNodeNetwork implements JingleS5BNetwork {
	/** Connection timeout in milliseconds **/
	public var timeout:Int;

	public function new(timeout = 5000)
		this.timeout = timeout;

	public function connect(host:String, port:Int, callback:(error:Null<String>, connection:Null<JingleS5BConnection>) -> Void) {
		var done = false;
		final socket = js.node.Net.connect({host: host, port: port});
		socket.setTimeout(timeout);
		socket.once('connect', () -> {
			if (done)
				return;
			done = true;
			socket.setTimeout(0);
			callback(null, new NodeConnection(socket));
		});
		socket.once('timeout', () -> {
			if (done)
				return;
			done = true;
			socket.destroy();
			callback('timeout', null);
		});
		socket.once('error', (e:js.lib.Error) -> {
			if (done)
				return;
			done = true;
			callback(e.message, null);
		});
	}

	public function listen(onConnection:JingleS5BConnection->Void, callback:(error:Null<String>, port:Int) -> Void):() -> Void {
		final server = js.node.Net.createServer(socket -> onConnection(new NodeConnection(socket)));
		server.once('error', (e:js.lib.Error) -> callback(e.message, 0));
		server.listen({port: 0}, () -> callback(null, (server.address() : Dynamic).port));
		return () -> server.close();
	}

	public function addresses():Array<String> {
		final list = [];
		final interfaces = js.node.Os.networkInterfaces();
		for (name in interfaces.keys())
			for (i in interfaces.get(name)) {
				final info:Dynamic = i;
				if (!info.internal && (info.family == 'IPv4' || info.family == 4))
					list.push(info.address);
			}
		return list;
	}
}

private class NodeConnection implements JingleS5BConnection {
	public var onData:Bytes->Void = data -> {};
	public var onClose:() -> Void = () -> {};

	final socket:js.node.net.Socket;

	public function new(socket:js.node.net.Socket) {
		this.socket = socket;
		socket.on('data', (data:js.node.Buffer) -> onData(data.hxToBytes()));
		socket.on('close', () -> onClose());
		socket.on('error', (e:js.lib.Error) -> {});
	}

	public function write(data:Bytes)
		socket.write(js.node.Buffer.hxFromBytes(data));

	public function close()
		socket.end();
}
#end
