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
				final error = session.onAction(req);
				respond((error == null) ? Response.success() : Response.fromError(error));
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
		Handle other actions (e.g. `transport-info`, `content-add`), return `null` to acknowledge the request
		or an error. By default answered with `feature-not-implemented`.
	**/
	public dynamic function onAction(request:JingleRequest):Null<xmpp.Stanza.Error>
		return new xmpp.Stanza.Error(cancel, feature_not_implemented);

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
		return send(session_initiate, contents, res -> {
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
		final iq = send(session_terminate, null, reason, handler);
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
			?handler:Response<XML>->Void):Null<IQ> {
		if (state == ended)
			return null;
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

	function end(reason:JingleReasonInfo) {
		if (state == ended)
			return;
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
	Transfer files with Jingle.

	Files are offered by the sender (`sendFile`) and transferred with in-band bytestreams (`JingleIBB`).
	The receiver accepts (`receiveFile`) or declines (`session.terminate(decline)`) the offer,
	verifies the size and the hash of the received data and terminates the session (`success` or `media-error`).

		jingle.onSessionInitiate = session -> {
			final file = JingleFileTransfer.getFileOffer(session);
			if (file == null)
				return session.terminate(unsupported_applications);
			JingleFileTransfer.receiveFile(session, (reason, data) -> trace(reason.condition, data?.length));
		}
		JingleFileTransfer.sendFile(jingle, 'juliet@example.com/balcony', {name: 'test.txt'}, bytes, reason -> trace(reason.condition));

	Not implemented: file requests (the receiver initiates), ranged transfers, multiple files per session,
	other transports (SOCKS5 bytestreams).

	[XEP-0234: Jingle File Transfer](https://xmpp.org/extensions/xep-0234.html)
**/
@xep(234)
class JingleFileTransfer {
	public static inline var XMLNS = "urn:xmpp:jingle:apps:file-transfer:5";
	public static inline var XMLNS_HASHES = "urn:xmpp:hashes:2";

	/** Features to advertise for service discovery **/
	public static final FEATURES = [XMLNS, JingleIBB.XMLNS];

	/**
		Offer `data` as `file` to `peer` (a full jid) and send it once accepted.

		The `size` and a `sha-256` hash are added to `file` if not set.
		`callback` is called once the session ended, with the reason: `success` if the receiver confirmed the transfer.
	**/
	@:noUsing
	public static function sendFile(jingle:Jingle, peer:String, file:JingleFile, data:Bytes, blockSize = JingleIBB.DEFAULT_BLOCK_SIZE,
			?onProgress:(sent:Int) -> Void, callback:(reason:JingleReasonInfo) -> Void):JingleSession {
		final file = Reflect.copy(file);
		file.size ??= data.length;
		if (file.hashes == null || file.hashes.length == 0)
			file.hashes = [hash(data)];
		final transport = JingleIBB.createTransport(xmpp.Stream.makeRandomId(), blockSize);
		final content:JingleContent = {
			creator: initiator,
			name: "a-file-offer",
			senders: initiator,
			description: createDescription(file),
			transport: transport
		};
		final session = jingle.createSession(peer);
		session.onTerminate = callback;
		session.onAccept = contents -> {
			final accepted = contents.filter(c -> c.name == content.name)[0];
			final ibb = (accepted == null) ? null : JingleIBB.parseTransport(accepted.transport);
			if (ibb == null || ibb.sid != transport.get("sid")) {
				session.terminate(unsupported_transports);
				return;
			}
			JingleIBB.send(session, ibb.sid, Std.int(Math.min(blockSize, ibb.blockSize)), data, onProgress, error -> {
				if (error != null)
					session.terminate(failed_transport, error.condition);
				// otherwise the receiver terminates the session after verifying the data
			});
		};
		session.initiate([content]);
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

		`callback` is called once the session ended: with the reason `success` and the data if the transfer succeeded.
		The data is verified with the offered size and hashes (if supported, e.g. `sha-1` and `sha-256`).
	**/
	@:noUsing
	public static function receiveFile(session:JingleSession, maxBlockSize = 65535, ?onProgress:(received:Int) -> Void,
			callback:(reason:JingleReasonInfo, data:Null<Bytes>) -> Void) {
		final content = getFileContent(session);
		final file = (content == null) ? null : parseDescription(content.description);
		final ibb = (content == null) ? null : JingleIBB.parseTransport(content.transport);
		var data:Null<Bytes> = null;
		session.onTerminate = reason -> callback(reason, (reason.condition == success) ? data : null);
		if (file == null) {
			session.terminate(unsupported_applications);
			return;
		}
		if (ibb == null) {
			session.terminate(unsupported_transports);
			return;
		}
		final blockSize = Std.int(Math.min(ibb.blockSize, maxBlockSize));
		JingleIBB.receive(session, ibb.sid, blockSize, file.size, onProgress, (error, received) -> {
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
		});
		final accepted:JingleContent = {
			creator: content.creator,
			name: content.name,
			senders: content.senders,
			description: content.description,
			transport: JingleIBB.createTransport(ibb.sid, blockSize)
		};
		session.accept([accepted]);
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

	static function digest(data:Bytes, algo:String):Null<Bytes>
		return switch algo {
			case "sha-1": haxe.crypto.Sha1.make(data);
			case "sha-256": haxe.crypto.Sha256.make(data);
			case _: null;
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
