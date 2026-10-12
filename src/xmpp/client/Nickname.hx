package xmpp.client;

import xmpp.IQ;

/**
	Communicate user nicknames: a global and memorable (but not necessarily unique) friendly
	or informal name asserted by an IM user.

	Rules:
	- Include the nickname in subscription requests and in the first message to a contact,
	  but not in ordinary presence broadcasts.
	- Publish nickname changes via PEP (`publishNickname`), read them from pubsub events with `parseNickname`.
	- Nicknames are not unique: never use them to validate the identity of an entity,
	  and warn users that a nickname may belong to someone else.

	[XEP-0172: User Nickname](https://xmpp.org/extensions/xep-0172.html)
**/
@xep(172)
class Nickname {
	public static inline var XMLNS = "http://jabber.org/protocol/nick";

	/**
		Sets the nickname of `stanza` (e.g. a subscription request), replacing an existing one; `null` removes it.
	**/
	public static function nickname<T:Stanza>(stanza:T, name:Null<String>):T {
		for (e in stanza.properties.copy())
			if (e.name == "nick" && e.is(XMLNS))
				stanza.properties.remove(e);
		if (name != null)
			stanza.properties.push(XML.create("nick", name).set("xmlns", XMLNS));
		return stanza;
	}

	/**
		Returns the nickname of `stanza`, or `null` if there is none (or it is empty).
	**/
	public static function getNickname<T:Stanza>(stanza:T):Null<String> {
		for (e in stanza.properties)
			if (e.name == "nick" && e.is(XMLNS))
				return parseNickname(e);
		return null;
	}

	/**
		Publish the user nickname via PEP, `null` to stop publishing it.
	**/
	public static function publishNickname(stream:xmpp.Stream, name:Null<String>, handler:Response<XML>->Void):IQ {
		final nick = (name == null) ? XML.create("nick") : XML.create("nick", name);
		nick.set("xmlns", XMLNS);
		final publish = XML.create("publish").set("node", XMLNS).append(XML.create("item").append(nick));
		return stream.set(Payload.create(PubSub.XMLNS, "pubsub").append(publish), handler);
	}

	/**
		Parses a `<nick/>` element (e.g. the payload of a pubsub event item),
		returns `null` if it is empty (the user stopped publishing a nickname).
	**/
	@:noUsing
	public static function parseNickname(xml:XML):Null<String> {
		final text:Null<String> = xml.text;
		return (text == null || text.length == 0) ? null : text;
	}
}
