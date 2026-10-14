import utest.Assert.*;
import Xml;
import xmpp.XML;

using xmpp.XML;

class TestXML extends utest.Test {
	function test_create() {
		var xml = XML.create("a");
		equals(XmlType.Element, xml.type);
		isNull(xml.parent);
		equals("a", xml.name);
		isNull(xml.text);
		equals(0, xml.elements.count());

		var xml = XML.create("a", "mycontent");
		equals(XmlType.Element, xml.type);
		isNull(xml.parent);
		equals("a", xml.name);
		equals("mycontent", xml.text);
		equals(0, xml.elements.count());

		xml = XML.create("a", ["x" => "1", "y" => "2"]);
		equals(XmlType.Element, xml.type);
		isNull(xml.parent);
		equals("a", xml.name);
		isNull(xml.text);
		equals("1", xml.get("x"));
		equals("2", xml.get("y"));
		equals(0, xml.elements.count());
	}

	function test_attributes() {
		var xml = XML.create('node').set('id', 'abc');

		isTrue(xml.has('id'));
		isFalse(xml.has('nope'));
		equals('abc', xml.get('id'));
		equals('abc', xml['id']);

		xml['id'] = 'xyz';
		isTrue(xml.has('id'));
		isFalse(xml.has('nope'));
		equals('xyz', xml.get('id'));
		equals('xyz', xml['id']);
	}

	function test_elements_length() {
		var xml:XML = '<a></a>';
		equals(0, xml.elements.length);
		xml = '<a><b></b></a>';
		equals(1, xml.elements.length);
	}

	/*
		function test_elements_find() {
			var xml = XML_SALES;
			//var item = xml.elements.doFind( e -> return e.get("type") == "chips" );
			//equals( 'chips', item.get("type") );
			xml.element["item"].find(element["type"] == "oranges")["quantity"] = "4";
			//var item = xml.elements.find( element["type"] == "chips" );
			equals( 'item', item.name );
			equals( '3', item['price'] );
		}
	 */
	function test_elements_first() {
		var xml:XML = '<a><b id="1"/><c id="2"/><b id="3"/></a>';
		equals('1', xml.elements.first().get('id'));
		equals('2', xml.elements.first(e -> e.name == 'c').get('id'));
		isNull(xml.elements.first(e -> e.name == 'x'));
		xml = '<a></a>';
		isNull(xml.elements.first());
	}

	function test_elements_reuse() {
		final xml:XML = '<a><b/>text<c id="1"/><c id="2"/></a>';
		final e = xml.elements;
		equals(3, e.count());
		equals(2, e.named('c').length);
		equals(2, e['c'].length);
		var n = 0;
		for (_ in e)
			n++;
		for (_ in e)
			n++;
		equals(6, n);
		equals('2', e[2].get('id'));
		isNull(e[3]);
		equals('1', e.findElement('c').get('id'));
		isNull(e.findElement('x'));
	}

	function test_insert() {
		var xml = XML.create('node');
		xml.append(XML.create('a'));
		xml.append(XML.create('b'));
		xml.append(XML.create('c'));
		equals(3, xml.elements.count());
		equals('a', xml.elements[0].name);
		equals('b', xml.elements[1].name);
		equals('c', xml.elements[2].name);
		xml.insert(XML.create('x'), 1);
		equals(4, xml.elements.count());
		equals('a', xml.elements[0].name);
		equals('x', xml.elements[1].name);
		equals('b', xml.elements[2].name);
		equals('c', xml.elements[3].name);
		xml.insert(XML.create('y'));
		equals(5, xml.elements.count());
		equals('y', xml.elements[0].name);
		equals('a', xml.elements[1].name);
		equals('x', xml.elements[2].name);
		equals('b', xml.elements[3].name);
		equals('c', xml.elements[4].name);
	}

	function test_is() {
		var xml:XML = '<node id="123">abc</node>';
		isFalse(xml.is('https://disktree.net'));
		xml = '<node xmlns="https://disktree.net" id="123">abc</node>';
		isTrue(xml.is('https://disktree.net'));
	}

	/*
		function test_primitive_bool() {
			var xml:XML = '<node>true</node>';
			equals('true', xml.text);
			isTrue(xml.text);

			xml = '<node>false</node>';
			equals('false', xml.text);
			isFalse(xml.text);
			
			xml = '<node></node>';
			isFalse(xml.text);

			xml = '<node>0</node>';
			isFalse(xml.text);

			xml = '<node>00</node>';
			equals('00', xml.text);
			var b : Bool = xml.text;
			isNull(b);

			xml = '<node>1</node>';
			isTrue(xml.text);

			xml = '<node>11</node>';
			equals('11', xml.text);
			var b : Bool = xml.text;
			isNull(b);
		}
	 */
	function test_primitive_float() {
		var xml = XML.create("node", "0.123");
		equals("0.123", xml.text);
		var f:Float = xml.text;
		equals(0.123, f);

		var xml = XML.create("node", ".123");
		equals(".123", xml.text);
		var f:Float = xml.text;
		equals(0.123, f);

		xml = XML.create("node");
		xml.text = 0.123;
		equals("0.123", xml.text);
		var f:Float = xml.text;
		equals(0.123, f);
	}

	function test_primitive_int() {
		var xml:XML = '<node>23</node>';
		equals('23', xml.text);
		var i:Int = xml.text;
		equals(23, i);
	}

	function test_text() {
		var xml = XML.create('node', 'value');
		equals('node', xml.name);
		equals('value', xml.text);
		xml.text = 'another';
		equals('another', xml.text);
		xml.text = null;
		isNull(xml.text);
	}

	function test_text_mixed() {
		var xml:XML = '<body><b>bold</b> text</body>';
		equals(' text', xml.text);

		xml = '<body>a<![CDATA[ < b]]> c</body>';
		equals('a < b c', xml.text);

		xml = '<a><b/></a>';
		isNull(xml.text);
		xml.text = 'v';
		equals('v', xml.text);
		equals(1, xml.elements.length);

		xml = '<a>one<b/>two</a>';
		xml.text = 'new';
		equals('new', xml.text);
		equals('b', xml.elements[0].name);
		xml.text = null;
		isNull(xml.text);
		equals(1, xml.elements.length);
	}

	function test_unset() {
		var xml = XML.create('node').set('id', 'abc').set("key", "value");
		notNull(xml.get('id'));
		notNull(xml.get('key'));
		xml.unset('id');
		isNull(xml.get('id'));
		notNull(xml.get('key'));
		isFalse(xml.has('id'));
		isTrue(xml.has('key'));
	}

	function test_print() {
		var src = '<node><child ns="my_ns">value</child></node>';
		var str = xmpp.xml.Printer.print(src, false);
		equals(src, str);
		var str = xmpp.xml.Printer.print(src, true);
		equals('<node>
	<child ns="my_ns">value</child>
</node>', str);
		final xml:xmpp.XML = Xml.parse(src).firstElement();
		equals(src, xmpp.xml.Printer.print(xml, false));
		equals('<a>  b &amp; c  </a>', xmpp.xml.Printer.print('<a>  b &amp; c  </a>', true));
		equals('<a>x <b>y</b> z</a>', xmpp.xml.Printer.print('<a>x <b>y</b> z</a>', true));
		equals('<stream:stream>', xmpp.xml.Printer.print('<stream:stream>', true));
	}
	/*
		function test_markup() {
			var x = XML.markup(<div id="myid">MyContent</div>);
			equals('div', x.name);
			equals('myid', x.get('id'));
			equals('MyContent', x.text);
		}
	 */
}
