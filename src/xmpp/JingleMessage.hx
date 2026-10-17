package xmpp;

import xmpp.Jingle;

/** The messages of a call being initiated **/
enum abstract JingleMessageAction(String) to String {
	/** The initiator proposes a call (to the bare jid of the responder: all its clients ring) **/
	var propose;

	/** A client of the responder rings (to the full jid of the initiator) **/
	var ringing;

	/** A client of the responder accepts: the initiator requests the session from it (`session-initiate`) **/
	var proceed;

	/** The responder accepted on one of its clients (older versions, to the own bare jid; now `proceed`) **/
	var accept;

	/** The responder declines (to the full jid of the initiator) **/
	var reject;

	/** The initiator withdraws the proposal before it is accepted **/
	var retract;

	/** The call ended, sent by both parties (to the full jid of the other) **/
	var finish;

	@:noCompletion public static function fromString(s:Null<String>):Null<JingleMessageAction>
		return switch s {
			case "propose" | "ringing" | "proceed" | "accept" | "reject" | "retract" | "finish": cast s;
			case _: null;
		}
}

/** A parsed message of a call being initiated **/
typedef JingleMessageInfo = {
	var action:JingleMessageAction;

	/** Identifies the call: the session id of its Jingle session **/
	var id:String;

	/** The media proposed (`propose`): `audio`, `video` **/
	var media:Array<String>;

	/** Why (e.g. `cancel` of a retraction, `busy` of a rejection, `success` of a finished call) **/
	var ?reason:JingleReasonInfo;

	/** A tie-break: two proposals at the same time, this one lost **/
	var tieBreak:Bool;

	/** The session id the call moved to (`finish`), e.g. after a lost connection **/
	var ?migrated:String;
}

/**
	Initiate calls by messages before the Jingle session: the initiator proposes the call to the bare jid of the
	responder, all its clients ring, the one accepting it (`proceed`) gets the session requested, the others stop
	ringing (the `proceed` of the accepting client reaches them as copy, see `Carbons`).

		stream.send(JingleMessage.create(bareJid, propose, sid, {media: ["audio"]}));
		// on proceed from a full jid: jingle.createSession(from, sid), then session.initiate(...)

	Rules:
	- The id is the session id of the following `session-initiate`.
	- All messages are of type `chat` with a storage hint: clients learn of calls also from the archive
	  (`MessageArchive`); delayed messages tell of calls which may be over.
	- Accept (`proceed`) only after the user confirmed, or by a rule the user set (e.g. contacts in the roster).
	- The protocol defines no service discovery feature; clients implementing it advertise `XMLNS`.

	[XEP-0353: Jingle Message Initiation](https://xmpp.org/extensions/xep-0353.html)
**/
@xep(353)
class JingleMessage {
	public static inline var XMLNS = "urn:xmpp:jingle-message:0";

	static inline var XMLNS_HINTS = "urn:xmpp:hints";

	/**
		Creates a message of `action` for the call `id` to `to`: of type `chat`, with the storage hint.
		`media` for a proposal, `reason` e.g. for a retraction, rejection or finish.
	**/
	@:noUsing
	public static function create(to:String, action:JingleMessageAction, id:String, ?options:{
		?media:Array<String>,
		?reason:JingleReasonInfo,
		?tieBreak:Bool,
		?migrated:String
	}):Message {
		final e = XML.create(action).set("xmlns", XMLNS).set("id", id);
		if (options?.media != null)
			for (media in options.media)
				e.append(XML.create("description").set("xmlns", JingleRtp.XMLNS).set("media", media));
		if (options?.reason != null)
			e.append(Jingle.createReason(options.reason).set("xmlns", Jingle.XMLNS));
		if (options?.tieBreak == true)
			e.append(XML.create("tie-break"));
		if (options?.migrated != null)
			e.append(XML.create("migrated").set("to", options.migrated));
		final message = new Message(to, null, null, chat);
		message.properties.push(e);
		message.properties.push(XML.create("store").set("xmlns", XMLNS_HINTS));
		return message;
	}

	/**
		Returns the message of a call being initiated in `message`, or `null`.
	**/
	public static function parse(message:Message):Null<JingleMessageInfo> {
		for (e in message.properties) {
			final action = JingleMessageAction.fromString(e.name);
			if (action == null || !e.is(XMLNS) || e.get("id") == null)
				continue;
			final reason = e.elements.first(r -> r.name == "reason");
			final migrated = e.elements.first(m -> m.name == "migrated");
			final info:JingleMessageInfo = {
				action: action,
				id: e.get("id"),
				media: [
					for (d in e.elements)
						if (d.name == "description" && d.is(JingleRtp.XMLNS) && d.get("media") != null) d.get("media")
				],
				tieBreak: e.elements.first(t -> t.name == "tie-break") != null
			};
			if (reason != null)
				info.reason = Jingle.parseReason(reason);
			if (migrated?.get("to") != null)
				info.migrated = migrated.get("to");
			return info;
		}
		return null;
	}
}
