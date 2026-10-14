import utest.Assert.*;
import xmpp.URI;

class TestURI extends utest.Test {
	function test_parse() {
		var str = "xmpp:example.com";
		var uri = URI.parse(str);
		equals("example.com", uri.jid);
		isNull(uri.action);
		equals(0, Lambda.count(uri.params));

		// authority only: the account to use, no target
		str = "xmpp://guest@example.com";
		uri = URI.parse(str);
		equals("guest@example.com", uri.account);
		isNull(uri.jid);
		isNull(uri.action);
		equals(0, Lambda.count(uri.params));

		str = "xmpp:user@example.com?message;body=hi";
		uri = URI.parse(str);
		equals("user@example.com", uri.jid);
		equals("message", uri.action);
		equals("hi", uri.params.get("body"));
		equals(1, Lambda.count(uri.params));

		//xmpp:romeo@montague.net?roster
		//xmpp:example-node@example.com?message;subject=Hello%20World
		//xmpp:romeo@montague.net?message;subject=Test%20Message;body=Here%27s%20a%20test%20message
	}

	function test_message_action() {
		var str = "xmpp:romeo@montague.net?message";
		var uri = URI.parse(str);
		equals("romeo@montague.net", uri.jid);
		equals("message", uri.action);

		str = "xmpp:romeo@montague.net?message;subject=Test%20Message;body=Here%27s%20a%20test%20message";
		uri = URI.parse(str);
		equals("romeo@montague.net", uri.jid);
		equals("message", uri.action);
		equals(2, Lambda.count(uri.params));
	}

	function test_equals() {
		var a = URI.parse("xmpp:romeo@montague.net?roster");
		var b = URI.parse("xmpp:romeo@montague.net?roster");
		isTrue(a.equalsTo(b));
		isTrue(a == b);
	}

	function test_clone() {
		var a = URI.parse("xmpp:romeo@montague.net?roster");
		var b = a.clone();
		isTrue(a.equalsTo(b));
		isTrue(a == b);
	}

	function test_muc() {
		var uri = URI.parse("xmpp:prosody@conference.prosody.im?join");
		equals("prosody@conference.prosody.im", uri.jid);
		isNull(uri.account);
		equals("join", uri.action);
		//xmpp:prosody@conference.prosody.im?join
	}

	function test_uri() {
		var uri = URI.parse('xmpp:romeo@montague.net');
		equals('romeo@montague.net', uri.jid);
		isNull(uri.action);
		isNull(uri.account);

		uri = URI.parse('xmpp:romeo@montague.net?message;subject=Test%20Message;body=Here%27s%20a%20test%20message');
		equals('message', uri.action);
		equals('Test Message', uri.params.get('subject'));
		equals("Here's a test message", uri.params.get('body'));

		uri = URI.parse('xmpp://guest@example.com/support@example.com?message');
		equals('guest@example.com', uri.account);
		equals('support@example.com', uri.jid);
		equals('message', uri.action);

		uri = URI.parse('xmpp:example-node@example.com?message;body=hi');
		equals('xmpp:example-node@example.com?message;body=hi', uri.toString());
		equals('xmpp:romeo@montague.net', URI.parse('xmpp:romeo@montague.net').toString());
		equals('xmpp://guest@example.com/support@example.com?message', URI.parse('xmpp://guest@example.com/support@example.com?message').toString());

		isTrue(URI.parse('xmpp:a@b?message;body=x') == URI.parse('xmpp:a@b?message;body=x'));
		isFalse(URI.parse('xmpp:a@b?message;body=x') == URI.parse('xmpp:a@b?message'));
		isNull(URI.parse('mailto:a@b'));
	}

	function test_uri_encoding() {
		// '+' is a literal character
		equals('user+tag@example.com', URI.parse('xmpp:user+tag@example.com').jid);
		equals('1+1', URI.parse('xmpp:a@b?message;body=1+1').params.get('body'));

		// https://xmpp.org/rfcs/rfc5122.html#iri-uri (non-ascii as percent-encoded utf-8)
		final u = URI.parse('xmpp:ji%C5%99i@%C4%8Dechy.example/v%20Praze');
		equals('jiři@čechy.example/v Praze', u.jid);
		equals('xmpp:ji%C5%99i@%C4%8Dechy.example/v%20Praze', u.toString());

		// characters with a meaning in the uri are encoded
		final u:URI = {jid: 'room@conf.example.com/nick?x#y;z', action: 'join', account: null, params: ['password' => 'a;b=c&d']};
		final str = u.toString();
		equals('xmpp:room@conf.example.com/nick%3Fx%23y%3Bz?join;password=a%3Bb%3Dc%26d', str);
		isTrue(URI.parse(str) == u);

		// characters outside the BMP
		final u:URI = {jid: 'a@b', action: 'message', account: null, params: ['body' => 'hi 😀']};
		equals('hi 😀', URI.parse(u.toString()).params.get('body'));

		// parameters are sorted
		final u:URI = {jid: 'a@b', action: 'message', account: null, params: ['subject' => 's', 'body' => 'b']};
		equals('xmpp:a@b?message;body=b;subject=s', u.toString());

		// invalid escapes are kept
		equals('100%', URI.parse('xmpp:a@b?message;body=100%').params.get('body'));

		final u = URI.parse('xmpp:a@b');
		isFalse(u == null);
		isFalse(null == u);
		isTrue(u != null);
	}
}
