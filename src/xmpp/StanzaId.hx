package xmpp;

/**
	Unique and stable ids of messages, assigned by the entity routing or archiving them (`stanza-id`), and by the
	sender (`origin-id`).

	A `stanza-id` may only be trusted if it was added by the entity named in `by`, and that entity announces support
	(`XMLNS`, e.g. a room or the own server): otherwise anybody could forge it. `getStanzaId` returns only the id by
	the given entity.

	@see [XEP-0359: Unique and Stable Stanza IDs](https://xmpp.org/extensions/xep-0359.html)
**/
@xep(359)
class StanzaId {
	public static inline var XMLNS = "urn:xmpp:sid:0";

	/**
		Returns the `stanza-id` of `message` added by `by` (a bare jid, e.g. the room of a groupchat message), or `null`.
	**/
	public static function getStanzaId(message:xmpp.Message, by:String):Null<String> {
		if (by == null)
			return null;
		final jid = Jid.normalize(by);
		for (e in message.properties)
			if (e.name == "stanza-id" && e.is(XMLNS) && e.get("by") != null && Jid.normalize(e.get("by")) == jid)
				return e.get("id");
		return null;
	}

	/**
		Returns the `origin-id` of `message` (set by its sender), or `null`.
	**/
	public static function getOriginId(message:xmpp.Message):Null<String> {
		for (e in message.properties)
			if (e.name == "origin-id" && e.is(XMLNS))
				return e.get("id");
		return null;
	}

	/**
		Sets the `origin-id` of `message`: `id`, or the id of the message (a new one if it has none).
	**/
	public static function setOriginId(message:xmpp.Message, ?id:String):xmpp.Message {
		for (e in message.properties.copy())
			if (e.name == "origin-id" && e.is(XMLNS))
				message.properties.remove(e);
		if (id == null) {
			if (message.id == null)
				message.id = Stream.makeRandomId();
			id = message.id;
		}
		message.properties.push(XML.create("origin-id").set("xmlns", XMLNS).set("id", id));
		return message;
	}
}
