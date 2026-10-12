package xmpp;

/**
	Extension for getting the attention of another user.

	A client supporting it MUST advertise the `XMLNS` feature in its service discovery responses,
	only while enabled by the user, and SHOULD accept attention requests only from contacts
	in the roster or with directed presence.

	[XEP-0224: Attention](https://xmpp.org/extensions/xep-0224.html)
**/
@xep(224)
class Attention {
	public static inline var XMLNS = "urn:xmpp:attention:0";

	/**
		Adds the attention request to the given message and sets its type to `headline`,
		so it is not stored offline.
	**/
	public static function captureAttention(message:xmpp.Message):xmpp.Message {
		message.type = headline;
		if (!hasAttention(message))
			message.properties.push(XML.create("attention").set('xmlns', XMLNS));
		return message;
	}

	/**
		Returns `true` if the message requests attention.

		Delayed messages (e.g. offline messages) are ignored, an attention request is not replayed after a delay.
	**/
	public static function wantsAttention(message:xmpp.Message):Bool {
		if (!hasAttention(message))
			return false;
		for (e in message.properties)
			if (e.name == "delay" && e.is(DelayedDelivery.XMLNS))
				return false;
		return true;
	}

	static function hasAttention(message:xmpp.Message):Bool {
		for (e in message.properties)
			if (e.name == "attention" && e.is(XMLNS))
				return true;
		return false;
	}
}
