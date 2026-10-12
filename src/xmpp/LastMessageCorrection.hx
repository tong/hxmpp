package xmpp;

/**
	Indicate that a message is a correction of the last sent message.

	Rules:
	- Messages can only be corrected if they were sent with an `id`; set one before sending
	  (e.g. `message.id = Stream.makeRandomId()`).
	- The correction is a complete replacement of the original message content, sent with a new `id`.
	- Corrections may only change the content, and MUST NOT be used for messages with non-messaging payloads.
	- Receivers MUST only accept corrections from the sender of the original message, see `isValidCorrection`.
	- A client implementing corrections MUST advertise the `XMLNS` feature in its service discovery responses.

	@see [XEP-0308: Last Message Correction](https://xmpp.org/extensions/xep-0308.html)
**/
@xep(308)
class LastMessageCorrection {
	public static inline var XMLNS = "urn:xmpp:message-correct:0";

	/**
		Marks `message` as correction of the message with the given `id`.

		Replaces an existing correction mark, and sets a new `id` on the message if it has none.
	**/
	public static function correct(message:xmpp.Message, id:String):xmpp.Message {
		if (id == null)
			return message;
		for (e in message.properties.copy())
			if (e.name == "replace" && e.is(XMLNS))
				message.properties.remove(e);
		message.properties.push(XML.create("replace").set('xmlns', XMLNS).set('id', id));
		if (message.id == null)
			message.id = Stream.makeRandomId();
		return message;
	}

	/**
		Returns the id of the message corrected by the given message, or `null` if it is no correction.
	**/
	public static function correction(message:xmpp.Message):Null<String> {
		for (e in message.properties)
			if (e.name == "replace" && e.is(XMLNS))
				return e.get('id');
		return null;
	}

	/**
		Returns `true` if `correction` is a valid correction of `original`: it refers to the id of the original
		and was sent by the same sender (the same full jid in groupchats, the same bare jid otherwise).
	**/
	@:noUsing
	public static function isValidCorrection(original:xmpp.Message, correction:xmpp.Message):Bool {
		final id = LastMessageCorrection.correction(correction);
		if (id == null || original.id == null || id != original.id)
			return false;
		final a = original.from;
		final b = correction.from;
		if (a == null || b == null)
			return a == b;
		return (original.type == groupchat) ? Jid.normalize(a) == Jid.normalize(b) : Jid.normalize(Jid.parseBare(a)) == Jid.normalize(Jid.parseBare(b));
	}
}
