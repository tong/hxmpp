package xmpp;

import xmpp.IQ;

typedef Carbon = {
	/** `true` for a message sent by another resource of the user, `false` for a message received by another resource **/
	var sent:Bool;

	/** The copied message **/
	var message:Message;
}

/**
	Carbon copy outbound messages to all interested resources.

	Once enabled, the server sends copies of the messages sent and received by the other resources of the user.
	Use `getCarbon` to read them.

	Clients MUST NOT auto-reply to copied messages, and SHOULD NOT send a `gone` chat state on logout.

	[XEP-0280: Message Carbons](https://xmpp.org/extensions/xep-0280.html)
**/
@xep(280)
class Carbons {
	public static inline var XMLNS = "urn:xmpp:carbons:2";

	/** Feature advertised by servers that follow the exact rules of which messages are copied **/
	public static inline var XMLNS_RULES = "urn:xmpp:carbons:rules:0";

	static inline var XMLNS_FORWARD = "urn:xmpp:forward:0";
	static inline var XMLNS_HINTS = "urn:xmpp:hints";

	/**
		Enable receiving carbon copies.
	**/
	public static inline function enableMessageCarbons(stream:Stream, handler:Response<XML>->Void):IQ
		return stream.set(Payload.create(XMLNS, "enable"), handler);

	/**
		Disable receiving carbon copies.
	**/
	public static inline function disableMessageCarbons(stream:Stream, handler:Response<XML>->Void):IQ
		return stream.set(Payload.create(XMLNS, "disable"), handler);

	/**
		Returns the carbon copy contained in `message`, or `null` if it is no carbon copy.

		Copies not sent by the bare jid of the stream are ignored (`null`), since these may be forged by other entities.
	**/
	public static function getCarbon(stream:Stream, message:Message):Null<Carbon> {
		for (e in message.properties) {
			if ((e.name != "sent" && e.name != "received") || !e.is(XMLNS))
				continue;
			if (!isFromOwnBareJid(stream, message.from))
				return null;
			final forwarded = e.elements.first(f -> f.name == "forwarded" && f.is(XMLNS_FORWARD));
			if (forwarded == null)
				return null;
			final copy = forwarded.elements.findElement("message");
			if (copy == null)
				return null;
			return {sent: e.name == "sent", message: Message.fromXML(copy)};
		}
		return null;
	}

	/**
		Mark `message` to not be carbon copied to the other resources.
	**/
	public static function makePrivate(message:Message):Message {
		if (message.properties.filter(e -> e.name == "private" && e.is(XMLNS)).length == 0)
			message.properties.push(XML.create("private").set("xmlns", XMLNS));
		if (message.properties.filter(e -> e.name == "no-copy" && e.is(XMLNS_HINTS)).length == 0)
			message.properties.push(XML.create("no-copy").set("xmlns", XMLNS_HINTS));
		return message;
	}

	static function isFromOwnBareJid(stream:Stream, from:Null<String>):Bool {
		if (from == null || stream.jid == null || Jid.parseResource(from) != null)
			return false;
		return from.toLowerCase() == Jid.parseBare(stream.jid).toLowerCase();
	}
}
