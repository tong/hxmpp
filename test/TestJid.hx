import utest.Assert.*;
import xmpp.Jid;

class TestJid extends utest.Test {
	function test_ereg() {
		isTrue(Jid.EREG.match('node@domain.net/Resource'));
		equals('node@domain.net/Resource', Jid.EREG.matched(1));
		equals('node', Jid.EREG.matched(2));
		equals('domain.net', Jid.EREG.matched(3));
		equals('/Resource', Jid.EREG.matched(4));
		equals('Resource', Jid.EREG.matched(5));

		isTrue(Jid.EREG.match('node@domain/Resource'));
		equals('node@domain/Resource', Jid.EREG.matched(1));
		equals('node', Jid.EREG.matched(2));
		equals('domain', Jid.EREG.matched(3));
		equals('/Resource', Jid.EREG.matched(4));
		equals('Resource', Jid.EREG.matched(5));

		isTrue(Jid.EREG.match('node@domain'));
		equals('node@domain', Jid.EREG.matched(1));
		equals('node', Jid.EREG.matched(2));
		equals('domain', Jid.EREG.matched(3));
		isNull(Jid.EREG.matched(4));
		isNull(Jid.EREG.matched(5));
	}

	function test_validation() {
		isTrue(Jid.isValid("aaa"));
		isTrue(Jid.isValid("example.com"));
		isTrue(Jid.isValid("example.com/Resource"));
		isTrue(Jid.isValid("user+tag@x.org"));
		isTrue(Jid.isValid("jürgen@example.de/Wohnzimmer"));
		isTrue(Jid.isValid("node@domain/res@with/slash"));

		isFalse(Jid.isValid(null));
		isFalse(Jid.isValid(""));
		isFalse(Jid.isValid("@domain"));
		isFalse(Jid.isValid("node@"));
		isFalse(Jid.isValid("node@domain/"));
		isFalse(Jid.isValid("a@b@c"));
		isFalse(Jid.isValid("no de@domain"));
		isFalse(Jid.isValid("node@do main"));
		isFalse(Jid.isValid(StringTools.lpad("", "a", Jid.MAX_PARTSIZE + 1) + "@domain"));

		isTrue(Jid.isValid("node@domain"));
		isTrue(Jid.isValid("node@domain/Resource"));
		isTrue(Jid.isValid("node@domain.net/Resource"));
		isTrue(Jid.isValid("node@domain.net"));
		isTrue(Jid.isValid("node@sub.domain.com"));
		isTrue(Jid.isValid("node@sub.domain.com/Resource"));
		isTrue(Jid.isValid("node@dd.net"));
	}

	function test_parse() {
		var parts = Jid.parseParts("node@domain.net/Resource");
		equals("node", parts[0]);
		equals("domain.net", parts[1]);
		equals("Resource", parts[2]);

		parts = Jid.parseParts("node@domain.net");
		equals("node", parts[0]);
		equals("domain.net", parts[1]);
		isNull(parts[2]);

		equals("node", Jid.parseNode("node@domain.net/Resource"));
		equals("domain.net", Jid.parseDomain("node@domain.net/Resource"));
		equals("Resource", Jid.parseResource("node@domain.net/Resource"));

		equals('domain.net', Jid.parseDomain('node@domain.net/Resource'));
		equals('domain.net', Jid.parseDomain('node@domain.net'));
		equals('domain', Jid.parseDomain('node@domain'));

		equals('Resource', Jid.parseResource('node@domain.net/Resource'));
		isNull(Jid.parseResource('node@domain.net'));
		isNull(Jid.parseResource('node@domain'));

		equals('node@domain.net', Jid.parseBare('node@domain.net/Resource'));
		equals('node@domain.net', Jid.parseBare('node@domain.net'));
		equals('node@domain', Jid.parseBare('node@domain'));

		parts = Jid.parseParts("example.com");
		isNull(parts[0]);
		equals("example.com", parts[1]);
		isNull(parts[2]);
		isNull(Jid.parseNode("example.com/Resource"));
		equals("example.com", Jid.parseDomain("example.com/Resource"));
		equals("example.com", Jid.parseBare("example.com/Resource"));

		// resource may contain '@' and '/'
		parts = Jid.parseParts("example.com/a@b/c");
		isNull(parts[0]);
		equals("example.com", parts[1]);
		equals("a@b/c", parts[2]);
		equals("node", Jid.parseNode("node@example.com/a@b"));
	}

	function test_domain_only() {
		var jid:Jid = "example.com";
		isNull(jid.node);
		equals("example.com", jid.domain);
		isNull(jid.resource);
		equals("example.com", jid.getBare());
		equals("example.com", jid.toString());

		var jid = new Jid(null, "example.com", "res");
		equals("example.com", jid.getBare());
		equals("example.com/res", jid.toString());
	}

	function test_from() {
		var jid:Jid = "node@domain.net/Resource";
		equals("node", jid.node);
		equals("domain.net", jid.domain);
		equals("Resource", jid.resource);

		var jid:Jid = ["node", "domain.net", "Resource"];
		equals("node", jid.node);
		equals("domain.net", jid.domain);
		equals("Resource", jid.resource);
	}

	function test_to() {
		var jid:Jid = "node@domain.net/Resource";

		var str:String = jid;
		equals("node@domain.net/Resource", str);

		var arr:Array<String> = jid;
		equals("node", arr[0]);
		equals("domain.net", arr[1]);
		equals("Resource", arr[2]);
	}

	function test_escape() {
		var str = 'joe smith"hugo&karl\\tom/che:ruth<elias>rotz@coma\\\\';
		equals(str, Jid.unescapeNode(Jid.escapeNode(str)));

		var str = '1\\202\\223\\264\\275\\2f6\\3a7\\3c8\\3e9\\4010\\5c';
		equals("1 2\"3&4'5/6:7<8>9@10\\", Jid.unescapeNode(str));
		// a trailing backslash is not followed by an escape sequence, so not escaped (XEP-0106)
		equals('1\\202\\223\\264\\275\\2f6\\3a7\\3c8\\3e9\\4010\\', Jid.escapeNode(Jid.unescapeNode(str)));
	}

	function test_equals() {
		var a = new Jid('romeo', 'server.com', 'balcony');
		var b = new Jid('julia', 'host.net', 'castle');
		isFalse(a.equals(b));
		isFalse(a == b);

		var a = new Jid('romeo', 'server.com', 'balcony');
		var b = new Jid('romeo', 'server.com', 'balcony');
		isTrue(a.equals(b));
		isTrue(a == b);
	}

	function test_arrayaccess() {
		var a = new Jid('romeo', 'server.com', 'balcony');
		equals('romeo', a[0]);
		equals('server.com', a[1]);
		equals('balcony', a[2]);
		equals('romeo@server.com/balcony', a[3]);
		equals('romeo@server.com/balcony', a[999]);
		equals('romeo@server.com/balcony', a[-1]);

		a[0] = 'julia';
		a[1] = 'another.com';
		a[2] = 'woods';

		equals('julia', a[0]);
		equals('another.com', a[1]);
		equals('woods', a[2]);
		equals('julia@another.com/woods', a[3]);
		equals('julia@another.com/woods', a[999]);
		equals('julia@another.com/woods', a[-1]);
	}

	function test_struct() {
		var jid:Jid = {node: 'node', domain: 'example.com', resource: 'hxmpp'};
		equals('node', jid.node);
		equals('example.com', jid.domain);
		equals('hxmpp', jid.resource);
		jid = {domain: "example.com"};
		equals("example.com", jid.domain);
		isNull(jid.node);
		isNull(jid.resource);
	}

	function test_escape_xep() {
		// https://xmpp.org/extensions/xep-0106.html#examples
		final examples = [
			['space cadet', 'space\\20cadet'],
			['call me "ishmael"', 'call\\20me\\20\\22ishmael\\22'],
			['at&t guy', 'at\\26t\\20guy'],
			["d'artagnan", 'd\\27artagnan'],
			['/.fanboy', '\\2f.fanboy'],
			['::foo::', '\\3a\\3afoo\\3a\\3a'],
			['<foo>', '\\3cfoo\\3e'],
			['user@host', 'user\\40host'],
			['c:\\net', 'c\\3a\\net'],
			['c:\\\\net', 'c\\3a\\\\net'],
			['c:\\cool stuff', 'c\\3a\\cool\\20stuff'],
			['c:\\5commas', 'c\\3a\\5c5commas'],
		];
		for (e in examples) {
			equals(e[1], Jid.escapeNode(e[0]));
			equals(e[0], Jid.unescapeNode(e[1]));
		}
		// \20 must not be first or last
		equals('space\\20cadet', Jid.escapeNode('  space cadet '));
		// unknown sequences are kept
		equals('a\\41b', Jid.unescapeNode('a\\41b'));
	}

	function test_compare() {
		final a:Jid = 'Juliet@Capulet.com/balcony';
		final b:Jid = 'juliet@capulet.com/balcony';
		final c:Jid = 'juliet@capulet.com/Balcony';
		isTrue(a == b);
		isFalse(a != b);
		isTrue(a.equals(b));
		isFalse(a == c);
		isTrue(a != c);
		equals('juliet@capulet.com/Balcony', Jid.normalize('JULIET@CAPULET.COM/Balcony'));
		equals('capulet.com', Jid.normalize('Capulet.COM'));

		final n:Jid = null;
		isTrue(n == null);
		isFalse(a == null);
		isTrue(a != null);
		isFalse(a.equals(null));
	}

	function test_from_null() {
		final s:String = null;
		final j:Jid = s;
		isTrue(j == null);
	}
}
