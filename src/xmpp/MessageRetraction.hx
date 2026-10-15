package xmpp;

/** A retraction: the id of the retracted message, for a moderation (XEP-0425) also the moderator and reason **/
typedef Retraction = {
	/** The id of the retracted message: the `stanza-id` of the room in rooms, else the id of the message **/
	var id:String;

	/** Retracted by a moderator of the room: the moderator's occupant jid (`null` if the room doesn't tell) **/
	var ?moderatedBy:String;

	/** A moderation of the room (`moderatedBy` may be unknown) **/
	var moderated:Bool;

	var ?reason:String;
}

/**
	Retracts (deletes) a sent message: the receiving clients hide it or show that it was retracted.

	A retraction refers to the message by its id: the `stanza-id` assigned by the room for groupchat messages (see
	`StanzaId`), else the `id` of the message. It has a fallback body for clients not supporting retractions.

	Rules:
	- Receivers MUST only accept retractions of the sender of the original message (the same bare jid, in rooms the
	  same occupant), or of the room for moderations (XEP-0425, see `MessageModeration`).
	- A retraction can't guarantee the message is deleted: other clients may have kept it.
	- A client implementing retractions MUST advertise the `XMLNS` feature in its service discovery responses.

	@see [XEP-0424: Message Retraction](https://xmpp.org/extensions/xep-0424.html)
**/
@xep(424)
class MessageRetraction {
	public static inline var XMLNS = "urn:xmpp:message-retract:1";

	/** The fallback body for clients not supporting retractions **/
	public static inline var FALLBACK = "/me retracted a previous message, but it's unsupported by your client.";

	static inline var XMLNS_HINTS = "urn:xmpp:hints";

	/**
		Makes `message` a retraction of the message with the given `id`: sets the fallback body (`fallback`, `FALLBACK`
		if not given) marked as fallback, a storage hint, and a new `id` if the message has none.
	**/
	public static function retract(message:xmpp.Message, id:String, ?fallback:String):xmpp.Message {
		for (e in message.properties.copy())
			if ((e.name == "retract" && e.is(XMLNS)) || (e.name == "fallback" && e.is(Fallback.XMLNS) && e.get("for") == XMLNS))
				message.properties.remove(e);
		message.properties.push(XML.create("retract").set("xmlns", XMLNS).set("id", id));
		message.body = fallback ?? FALLBACK;
		Fallback.add(message, XMLNS);
		if (!Lambda.exists(message.properties, e -> e.name == "store" && e.is(XMLNS_HINTS)))
			message.properties.push(XML.create("store").set("xmlns", XMLNS_HINTS));
		if (message.id == null)
			message.id = Stream.makeRandomId();
		return message;
	}

	/**
		Returns the retraction in `message`, or `null` if it is none.

		A moderation (`moderated`) is only valid if `message` was sent by the room itself (its bare jid).
	**/
	public static function getRetraction(message:xmpp.Message):Null<Retraction> {
		for (e in message.properties) {
			if (e.name != "retract" || !e.is(XMLNS) || e.get("id") == null)
				continue;
			final moderated = e.elements.first(m -> m.name == "moderated" && m.is(MessageModeration.XMLNS));
			final reason = e.elements.first(r -> r.name == "reason");
			final text:Null<String> = reason?.text;
			return {
				id: e.get("id"),
				moderated: moderated != null,
				moderatedBy: moderated?.get("by"),
				reason: (text != null && text.length > 0) ? text : null
			};
		}
		return null;
	}
}
