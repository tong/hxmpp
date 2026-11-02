package xmpp;

/**
	A block of a styled message body.
**/
enum StyledBlock {
	/** A line of text, without the line break **/
	Line(spans:Array<StyledSpan>);

	/** Preformatted text, between lines starting with ` ``` `: not styled **/
	Pre(text:String);

	/** Lines starting with `>`, without it: the blocks within, nested quotes too **/
	Quote(blocks:Array<StyledBlock>);
}

/**
	Styled text within a line.
	The directives (`*` etc.) are not part of the text, displaying them is recommended.
**/
enum StyledSpan {
	Plain(text:String);

	/** `*strong*` **/
	Strong(spans:Array<StyledSpan>);

	/** `_emphasis_` **/
	Emphasis(spans:Array<StyledSpan>);

	/** `~strike~` **/
	Strike(spans:Array<StyledSpan>);

	/** `` `code` ``: not styled **/
	Code(text:String);
}

/**
	Parses the plain text styling of message bodies: `*strong*`, `_emphasis_`, `~strike~`, `` `code` ``,
	preformatted blocks between ` ``` ` lines and `>` quotes.

	Styling is a way to display the body, it doesn't change it.
	The result is data, for any output: e.g. html elements or terminal colors.

	Rules:
	- A span opens at the start of a line or after a whitespace, the directive is not followed by a whitespace.
	- It closes at the first same directive not preceded by a whitespace, in the same line. Empty spans are text.
	- Spans nest, but not within code.
	- A preformatted block ends at a line of only ` ``` `, or at the end of the body or the quote it is in.
	- Not styled are messages with the `<unstyled/>` hint (see `isUnstyled`).
	- A client displaying styles SHOULD advertise the `XMLNS` feature in its service discovery responses.

	@see [XEP-0393: Message Styling](https://xmpp.org/extensions/xep-0393.html)
**/
@xep(393)
class MessageStyling {
	public static inline var XMLNS = "urn:xmpp:styling:0";

	/**
		Parses `body` into blocks.
	**/
	public static function parse(body:String):Array<StyledBlock>
		return blocks(body.split("\n"));

	/**
		Parses the spans of a single line.
	**/
	public static function parseLine(line:String):Array<StyledSpan> {
		final spans = new Array<StyledSpan>();
		var text = new StringBuf();
		var i = 0;
		while (i < line.length) {
			final c = line.charAt(i);
			final end = isDirective(c) && opens(line, i) ? closing(line, i) : -1;
			if (end == -1) {
				text.add(c);
				i++;
				continue;
			}
			final t = text.toString();
			if (t.length > 0)
				spans.push(Plain(t));
			text = new StringBuf();
			final inner = line.substring(i + 1, end);
			spans.push(switch c {
				case "*": Strong(parseLine(inner));
				case "_": Emphasis(parseLine(inner));
				case "~": Strike(parseLine(inner));
				case _: Code(inner);
			});
			i = end + 1;
		}
		final t = text.toString();
		if (t.length > 0)
			spans.push(Plain(t));
		return spans;
	}

	/**
		Returns `true` if the message has the hint not to style its body.
	**/
	public static function isUnstyled(message:xmpp.Message):Bool
		return Lambda.exists(message.properties, e -> e.name == "unstyled" && e.is(XMLNS));

	/**
		Adds the hint not to style the body, e.g. for text that is not meant to be styled.
	**/
	public static function unstyled(message:xmpp.Message):xmpp.Message {
		if (!isUnstyled(message))
			message.properties.push(XML.create("unstyled").set("xmlns", XMLNS));
		return message;
	}

	/**
		Returns the text of the spans, without the directives.
	**/
	public static function toPlainText(spans:Array<StyledSpan>):String {
		final b = new StringBuf();
		for (s in spans)
			b.add(switch s {
				case Plain(t) | Code(t): t;
				case Strong(s) | Emphasis(s) | Strike(s): toPlainText(s);
			});
		return b.toString();
	}

	static function blocks(lines:Array<String>):Array<StyledBlock> {
		final blocks = new Array<StyledBlock>();
		var i = 0;
		while (i < lines.length) {
			final line = lines[i];
			if (StringTools.startsWith(line, "```")) { // the rest of the line is ignored
				final pre = [];
				while (++i < lines.length && lines[i] != "```")
					pre.push(lines[i]);
				blocks.push(Pre(pre.join("\n")));
				i++;
			} else if (StringTools.startsWith(line, ">")) {
				final quote = [];
				while (i < lines.length && StringTools.startsWith(lines[i], ">")) {
					final l = lines[i++].substr(1);
					quote.push(StringTools.startsWith(l, " ") ? l.substr(1) : l);
				}
				blocks.push(Quote(MessageStyling.blocks(quote)));
			} else {
				blocks.push(Line(parseLine(line)));
				i++;
			}
		}
		return blocks;
	}

	static inline function isDirective(c:String):Bool
		return c == "*" || c == "_" || c == "~" || c == "`";

	/** At the start or after a whitespace, not followed by a whitespace **/
	static function opens(line:String, i:Int):Bool
		return (i == 0 || StringTools.isSpace(line, i - 1)) && i + 1 < line.length && !StringTools.isSpace(line, i + 1);

	/** Index of the closing directive of the span opening at `i`, or -1 **/
	static function closing(line:String, i:Int):Int {
		final c = line.charAt(i);
		var j = i + 2; // not empty
		while ((j = line.indexOf(c, j)) != -1) {
			if (!StringTools.isSpace(line, j - 1))
				return j;
			j++;
		}
		return -1;
	}
}
