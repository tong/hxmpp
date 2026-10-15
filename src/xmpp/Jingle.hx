package xmpp;

import xmpp.IQ;
import xmpp.JingleIBB;

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
	@:allow(xmpp.JingleIBB) final ibbReceivers = new Map<String, JingleIBBReceiver>();

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
		session.initiate(contents, null, handler);
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
			session.payload = req.info;
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
				session.payload = req.info;
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
		final req:JingleRequest = {
			action: action,
			sid: sid,
			contents: [],
			info: []
		};
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
				case "description":
					content.description = e;
				case "transport":
					content.transport = e;
				case "security":
					content.security = e;
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

	/**
		Other elements of the request and acceptance of the session than the contents (e.g. a `<group/>` of contents),
		as initiated and (once active) accepted
	**/
	public var payload(default, null):Array<XML> = [];

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
		Request the session (created by `Jingle.createSession`) with `contents` (and other elements, `payload`),
		the response acknowledges the request.
	**/
	public function initiate(contents:Array<JingleContent>, ?payload:Array<XML>, ?handler:Response<XML>->Void):Null<IQ> {
		if (!isInitiator || state != pending || initiated)
			return null;
		initiated = true;
		this.contents = contents;
		this.payload = payload ?? [];
		return send(session_initiate, contents, null, payload, (res:Response<XML>) -> {
			if (!res.ok())
				end({condition: general_error, text: res.error.condition});
			if (handler != null)
				handler(res);
		});
	}

	/**
		Accept a session initiated by the peer with `contents` (by default the initiated contents) and other elements
		(`payload`).
	**/
	public function accept(?contents:Array<JingleContent>, ?payload:Array<XML>, ?handler:Response<XML>->Void):Null<IQ> {
		if (isInitiator || state != pending)
			return null;
		state = active;
		if (contents != null)
			this.contents = contents;
		this.payload = payload ?? [];
		return send(session_accept, this.contents, null, payload, handler);
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

	function request(action:JingleAction, ?contents:Array<JingleContent>, ?reason:JingleReasonInfo, ?payload:Array<XML>, ?handler:Response<XML>->Void):IQ {
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
