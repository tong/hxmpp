package xmpp.xml;

using StringTools;

/**
	Xml, `xmpp.XML` or a string of XML.
**/
abstract Source(Any) from String from Xml {
	@:from static inline function fromXML(xml:xmpp.XML):Source
		return (xml : Xml);
}

/**
	Prints XML for display, e.g. logging stanzas.

	Pretty output puts each element on its own line, indented by tabs.
	Elements containing text are printed on a single line, so text content is never changed.
	Whitespace-only text between elements is dropped, so the output is meant for reading, not sending.
**/
class Printer {
	public var pretty:Bool;

	public function new(pretty = true)
		this.pretty = pretty;

	/**
		Prints a string of XML, returns it unchanged if not `pretty` or not parseable.
	**/
	public function printString(str:String):String {
		if (!pretty || str == null)
			return str;
		final xml = try Xml.parse(str) catch (e) return str;
		return printXml(xml);
	}

	public function printXml(xml:Xml):String {
		if (!pretty)
			return haxe.xml.Printer.print(xml);
		final buf = new StringBuf();
		write(buf, xml, "");
		return buf.toString();
	}

	public static function print(src:Source, pretty = true):String {
		if (src == null)
			return null;
		final printer = new Printer(pretty);
		return Std.isOfType(src, String) ? printer.printString(cast src) : printer.printXml(cast src);
	}

	static function write(buf:StringBuf, xml:Xml, indent:String) {
		if (xml.nodeType == Document) {
			var first = true;
			for (child in xml) {
				if (isBlank(child))
					continue;
				if (!first)
					buf.add("\n");
				first = false;
				write(buf, child, indent);
			}
			return;
		}
		buf.add(indent);
		if (xml.nodeType != Element || !hasOnlyElements(xml)) {
			buf.add(haxe.xml.Printer.print(xml));
			return;
		}
		buf.add('<${xml.nodeName}');
		for (name in xml.attributes())
			buf.add(' $name="${xml.get(name).htmlEscape(true)}"');
		buf.add(">");
		for (child in xml) {
			if (isBlank(child))
				continue;
			buf.add("\n");
			write(buf, child, indent + "\t");
		}
		buf.add('\n$indent</${xml.nodeName}>');
	}

	/** Whether `xml` has child elements (or comments) and no text **/
	static function hasOnlyElements(xml:Xml):Bool {
		var elements = false;
		for (child in xml)
			if (child.nodeType == Element || child.nodeType == Comment)
				elements = true;
			else if (!isBlank(child))
				return false;
		return elements;
	}

	static inline function isBlank(xml:Xml):Bool
		return xml.nodeType == PCData && xml.nodeValue.trim() == "";
}
