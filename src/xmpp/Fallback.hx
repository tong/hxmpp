package xmpp;

import haxe.iterators.StringIteratorUnicode;

/**
	Marks the parts of the body of a message which are only for clients not supporting an extension, e.g. the quote
	of a reply (`MessageReply`): clients supporting it leave them out.

	Ranges are offsets in Unicode code points of the body, from `start` (included) to `end` (excluded); a fallback
	without range is the whole body.

	@see [XEP-0428: Fallback Indication](https://xmpp.org/extensions/xep-0428.html)
**/
@xep(428)
class Fallback {
	public static inline var XMLNS = "urn:xmpp:fallback:0";

	/**
		Marks the body of `message` from `start` to `end` (code points; both `null`: all of it) as fallback for the
		extension `forNs` (its namespace).
	**/
	public static function add(message:xmpp.Message, forNs:String, ?start:Int, ?end:Int):xmpp.Message {
		final xml = XML.create("fallback").set("xmlns", XMLNS).set("for", forNs);
		if (start != null && end != null)
			xml.append(XML.create("body").set("start", Std.string(start)).set("end", Std.string(end)));
		message.properties.push(xml);
		return message;
	}

	/** Returns `true` if `message` has a fallback for the extension `forNs` **/
	public static function has(message:xmpp.Message, forNs:String):Bool {
		for (e in message.properties)
			if (e.name == "fallback" && e.is(XMLNS) && e.get("for") == forNs)
				return true;
		return false;
	}

	/**
		Returns the body of `message` without the fallback for the extension `forNs`: the body if it has none, `null`
		without body. Invalid ranges are ignored.
	**/
	public static function strip(message:xmpp.Message, forNs:String):Null<String> {
		final body = message.body;
		if (body == null)
			return null;
		final chars = [for (c in new StringIteratorUnicode(body)) c];
		final removed = [for (_ in chars) false];
		var found = false;
		for (e in message.properties) {
			if (e.name != "fallback" || !e.is(XMLNS) || e.get("for") != forNs)
				continue;
			found = true;
			final ranges = e.elements.named("body");
			if (ranges.length == 0)
				return "";
			for (r in ranges) {
				final start = Std.parseInt(r.get("start") ?? ""), end = Std.parseInt(r.get("end") ?? "");
				if (start == null || end == null || start < 0 || end < start || end > chars.length)
					continue;
				for (i in start...end)
					removed[i] = true;
			}
		}
		if (!found)
			return body;
		final b = new StringBuf();
		for (i in 0...chars.length)
			if (!removed[i])
				b.addChar(chars[i]);
		return b.toString();
	}

	/** The length of `text` in Unicode code points **/
	public static function length(text:String):Int {
		var n = 0;
		for (_ in new StringIteratorUnicode(text))
			n++;
		return n;
	}
}
