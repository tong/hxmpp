package xmpp;

/**
	Request and return receipts confirming that a message was received by the recipient's client.

	Rules:
	- A receipt is no guarantee: do not depend on receiving one, nor resend messages without.
	- Request receipts only of clients supporting them (see `ServiceDiscovery`/`EntityCapabilities`),
	  or when sending to a bare jid. Requesting receipts in groupchats is not recommended.
	- Return a receipt only when first receiving a message, not when viewing archived messages (e.g. MAM).
	- Return receipts only to senders authorized to view the presence, as they leak it.
	- A client supporting receipts MUST advertise the `XMLNS` feature in its service discovery responses.

	[XEP-0184: Message Delivery Receipts](https://xmpp.org/extensions/xep-0184.html)
**/
@xep(184)
class DeliveryReceipts {
	public static inline var XMLNS = "urn:xmpp:receipts";

	/**
		Requests a receipt for `message`, and sets an `id` on it if it has none.

		Nothing is added to error messages and receipts.
	**/
	public static function requestReceipt(message:Message):Message {
		if (message.type == error || isReceipt(message) || hasElement(message, "request"))
			return message;
		message.properties.push(XML.create("request").set("xmlns", XMLNS));
		if (message.id == null)
			message.id = Stream.makeRandomId();
		return message;
	}

	/**
		Returns `true` if `message` requests a receipt that can be returned.
	**/
	public static function wantsReceipt(message:Message):Bool
		return message.type != error && message.id != null && hasElement(message, "request") && !isReceipt(message);

	/**
		Returns the receipt for a received `message`, or `null` if it does not request one (see `wantsReceipt`).

		The receipt has the type of the message; in groupchats it is sent to the room.
	**/
	public static function createReceipt(message:Message):Null<Message> {
		if (!wantsReceipt(message) || message.from == null)
			return null;
		final to = (message.type == groupchat) ? Jid.parseBare(message.from) : message.from;
		final receipt = new Message(to, null, null, message.type);
		receipt.id = Stream.makeRandomId();
		receipt.properties.push(XML.create("received").set("xmlns", XMLNS).set("id", message.id));
		return receipt;
	}

	/**
		Returns the id of the message confirmed by `message`, or `null` if it is no receipt.
	**/
	public static function receipt(message:Message):Null<String> {
		for (e in message.properties)
			if (e.name == "received" && e.is(XMLNS))
				return e.get("id");
		return null;
	}

	static inline function isReceipt(message:Message):Bool
		return hasElement(message, "received");

	static function hasElement(message:Message, name:String):Bool {
		for (e in message.properties)
			if (e.name == name && e.is(XMLNS))
				return true;
		return false;
	}
}
