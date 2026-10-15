package xmpp;

/**
	Reactions (emojis) to a message.

	A reactions message refers to the message reacted to by its id: the `stanza-id` assigned by the room for
	groupchat messages (see `StanzaId`), else the `id` of the message (as for corrections). It holds all reactions of
	the sender to that message: each new one replaces the previous, none removes them.

	Rules:
	- Each reaction SHOULD be a single emoji; duplicates are ignored.
	- Reactions messages have no body, they carry a hint to be stored in archives.
	- A client implementing reactions MUST advertise the `XMLNS` feature in its service discovery responses.

	@see [XEP-0444: Message Reactions](https://xmpp.org/extensions/xep-0444.html)
**/
@xep(444)
class MessageReactions {
	public static inline var XMLNS = "urn:xmpp:reactions:0";

	static inline var XMLNS_HINTS = "urn:xmpp:hints";

	/**
		Adds the `reactions` (all of the sender, empty to remove them) to the message with the given `id` to `message`.

		Replaces existing reactions, and adds a storage hint (`<store/>`) and a new `id` if the message has none.
	**/
	public static function react(message:xmpp.Message, id:String, reactions:Array<String>):xmpp.Message {
		for (e in message.properties.copy())
			if (e.name == "reactions" && e.is(XMLNS))
				message.properties.remove(e);
		final xml = XML.create("reactions").set("xmlns", XMLNS).set("id", id);
		for (r in unique(reactions))
			xml.append(XML.create("reaction", r));
		message.properties.push(xml);
		if (!Lambda.exists(message.properties, e -> e.name == "store" && e.is(XMLNS_HINTS)))
			message.properties.push(XML.create("store").set("xmlns", XMLNS_HINTS));
		if (message.id == null)
			message.id = Stream.makeRandomId();
		return message;
	}

	/**
		Returns the reactions in `message`: the id of the message reacted to and the reactions of the sender (empty:
		removed), or `null` if it has none. Empty and duplicate reactions are left out.
	**/
	public static function getReactions(message:xmpp.Message):Null<{id:String, reactions:Array<String>}> {
		for (e in message.properties) {
			if (e.name != "reactions" || !e.is(XMLNS) || e.get("id") == null)
				continue;
			final texts = [
				for (r in e.elements.named("reaction")) {
					final text:String = r.text;
					text ?? "";
				}
			];
			return {id: e.get("id"), reactions: unique(texts)};
		}
		return null;
	}

	static function unique(reactions:Array<String>):Array<String> {
		final result = new Array<String>();
		for (r in reactions) {
			final r = StringTools.trim(r ?? "");
			if (r.length > 0 && !result.contains(r))
				result.push(r);
		}
		return result;
	}
}
