import utest.Assert.*;
import xmpp.Message;

class TestMessage extends utest.Test {
	function test_type() {
		equals('normal', MessageType.normal);
		equals('error', MessageType.error);
		equals('chat', MessageType.chat);
		equals('groupchat', MessageType.groupchat);
		equals('headline', MessageType.headline);

		equals(normal, cast('normal', MessageType));
		equals(error, cast('error', MessageType));
		equals(chat, cast('chat', MessageType));
		equals(groupchat, cast('groupchat', MessageType));
		equals(headline, cast('headline', MessageType));

		var s:MessageType = '';
		isNull(s);

		var s:MessageType = 'any';
		isNull(s);
	}

	function test_create() {
		var m = new Message();

		isNull(m.to);
		isNull(m.from);
		isNull(m.id);
		isNull(m.lang);
		// isNull( m.error );
		equals(chat, m.type);
		isNull(m.body);
		isNull(m.subject);
		isNull(m.thread);
		equals(0, m.properties.length);

		var m = new Message('node@domain.com/resource', 'mybody', 'mysubject');
		equals('node@domain.com/resource', m.to);
		equals('mybody', m.body);
		equals('mysubject', m.subject);
		equals('chat', m.type);
		isNull(m.thread);

		var xml = m.toXML();
		equals('node@domain.com/resource', xml.get('to'));
		equals(MessageType.chat, xml.get('type'));
		equals('mysubject', xml.elements.named('subject')[0].text);
		equals('mybody', xml.elements.named('body')[0].text);

		var m:Message = m.toString();
		equals('mysubject', m.subject);
		equals('mybody', m.body);
	}

	function test_fromString() {
		var m = Message.fromString('<message type="chat" to="romeo@example.net"><body>hi</body></message>');
		equals(chat, m.type);
		equals('romeo@example.net', m.to);
		equals('hi', m.body);

		var m:Message = '<message type="groupchat"><body>all</body></message>';
		equals(groupchat, m.type);
		equals('all', m.body);
	}

	function test_parse() {
		var xml = Xml.parse('<message type="chat"><body>mybody</body></message>').firstElement();
		var m = Message.fromXML(xml);
		equals('chat', m.type);
		equals('mybody', m.body);
		equals(0, m.properties.length);

		var xml = Xml.parse('
			<message to="romeo@jabber.disktree.net">
				<body>green with envy!</body>
				<html xmlns="http://jabber.org/protocol/xhtml-im">
					<body xmlns="http://www.w3.org/1999/xhtml">
						<p style="font-size:large">
							<em>Wow</em>, I&apos;m <span style="color:green">green</span>
							with <strong>envy</strong>!
						</p>
					</body>
				</html>
			</message>')
			.firstElement();
		var m = Message.fromXML(xml);
		// no type: normal (RFC 6121 5.2.2)
		equals(normal, m.type);
		equals('romeo@jabber.disktree.net', m.to);
		equals('green with envy!', m.body);
		equals(1, m.properties.length);
		equals("html", m.properties[0].name);
	}

	function test_parse_type() {
		equals(normal, Message.fromString('<message type="foo"><body>x</body></message>').type);
		equals(headline, Message.fromString('<message type="headline"><body>x</body></message>').type);
		// new messages are chat by default
		equals(chat, new Message('a@b', 'x').type);
	}

	function test_languages() {
		final m = Message.fromString('<message><subject xml:lang="de">Betreff</subject><subject>Subject</subject><body>Hello</body><body xml:lang="de">Hallo</body></message>');
		equals('Hello', m.body);
		equals('Subject', m.subject);
		equals(2, m.properties.length);
		final xml = Message.fromString(m.toString()).toXML();
		equals(2, xml.elements.named('body').length);
		equals(2, xml.elements.named('subject').length);

		// without default language: the first
		final m = Message.fromString('<message><body xml:lang="en">Hello</body><body xml:lang="de">Hallo</body></message>');
		equals('Hello', m.body);
		equals(1, m.properties.length);
	}

	function test_thread_parent() {
		final m = Message.fromString('<message type="chat"><body>x</body><thread parent="e0ffe42b28561960c6b12b944a092794b9683a38">7edac73ab41e45c4aafa7b2d7b749080</thread></message>');
		equals('7edac73ab41e45c4aafa7b2d7b749080', m.thread);
		equals('e0ffe42b28561960c6b12b944a092794b9683a38', m.threadParent);
		final thread = m.toXML().elements.named('thread')[0];
		equals('e0ffe42b28561960c6b12b944a092794b9683a38', thread.get('parent'));
		isFalse(new Message('a@b', 'x', null, chat, 't').toXML().elements.named('thread')[0].has('parent'));
	}

	function test_error() {
		final m = Message.fromString('<message type="error" from="romeo@example.net" id="m1"><body>hi</body><error type="cancel"><item-not-found xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></message>');
		equals(error, m.type);
		equals('item-not-found', (m.error.condition : String));
		final xml = m.toXML();
		equals(1, xml.elements.named('error').length);
		equals('item-not-found', Message.fromString(xml.toString()).error.condition);

		final p = xmpp.Presence.fromString('<presence type="error" from="romeo@example.net"><error type="auth"><forbidden xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></presence>');
		equals('forbidden', (xmpp.Presence.fromString(p.toString()).error.condition : String));
	}
}
