package xmpp;

/**
	Replies to a message.

	A reply refers to the message replied to by its id: the `stanza-id` assigned by the room for groupchat messages
	(see `StanzaId`), else the `id` of the message; and to its author by `to` (optional: the full jid, in rooms the
	occupant jid).

	For clients not supporting replies, the body can start with a quote of the message (lines starting with `> `),
	marked as fallback (`Fallback`): clients supporting replies leave it out, see `getBody`.

	A client implementing replies MUST advertise the `XMLNS` feature in its service discovery responses.

	@see [XEP-0461: Message Replies](https://xmpp.org/extensions/xep-0461.html)
**/
@xep(461)
class MessageReply {
	public static inline var XMLNS = "urn:xmpp:reply:0";

	/**
		Marks `message` as reply to the message with the given `id` by `to`.

		With `quote` (the text of the message replied to), the body starts with it quoted, marked as fallback.
		Replaces an existing reply mark, and sets a new `id` on the message if it has none.
	**/
	public static function reply(message:xmpp.Message, id:String, ?to:String, ?quote:String):xmpp.Message {
		for (e in message.properties.copy())
			if ((e.name == "reply" && e.is(XMLNS)) || (e.name == "fallback" && e.is(Fallback.XMLNS) && e.get("for") == XMLNS))
				message.properties.remove(e);
		final xml = XML.create("reply").set("xmlns", XMLNS).set("id", id);
		if (to != null)
			xml.set("to", to);
		message.properties.push(xml);
		if (quote != null && message.body != null) {
			final q = quoted(quote);
			message.body = q + message.body;
			Fallback.add(message, XMLNS, 0, Fallback.length(q));
		}
		if (message.id == null)
			message.id = Stream.makeRandomId();
		return message;
	}

	/**
		Returns what `message` replies to: the id of the message and its author (`to`, `null` if not given), or `null`
		if it is no reply.
	**/
	public static function getReply(message:xmpp.Message):Null<{id:String, ?to:String}> {
		for (e in message.properties)
			if (e.name == "reply" && e.is(XMLNS) && e.get("id") != null)
				return {id: e.get("id"), to: e.get("to")};
		return null;
	}

	/**
		Returns the body of `message` without the quote of the message replied to (its fallback), `null` without body.
	**/
	public static inline function getBody(message:xmpp.Message):Null<String>
		return Fallback.strip(message, XMLNS);

	/** `text` as quote: each line starting with `> `, ending with a line break **/
	public static function quoted(text:String):String
		return [for (l in text.split("\n")) '> $l\n'].join("");
}
