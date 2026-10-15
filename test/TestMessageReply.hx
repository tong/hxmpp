import utest.Assert.*;
import xmpp.Fallback;
import xmpp.Message;
import xmpp.MessageReply;

using xmpp.MessageReply;

class TestMessageReply extends utest.Test {
	function test_reply() {
		final m = new Message('anna@example.com', 'Great idea!').reply('message-id1', 'anna@example.com/laptop', 'We should bake a cake');
		final xml = m.toXML();
		final reply = xml.elements.named('reply')[0];
		equals(MessageReply.XMLNS, reply.get('xmlns'));
		equals('message-id1', reply.get('id'));
		equals('anna@example.com/laptop', reply.get('to'));
		equals('> We should bake a cake\nGreat idea!', m.body);
		final fallback = xml.elements.named('fallback')[0];
		equals(Fallback.XMLNS, fallback.get('xmlns'));
		equals(MessageReply.XMLNS, fallback.get('for'));
		equals('0', fallback.firstElement.get('start'));
		equals('24', fallback.firstElement.get('end'));
		notNull(m.id);

		final m:Message = m.toString();
		equals('message-id1', m.getReply().id);
		equals('anna@example.com/laptop', m.getReply().to);
		equals('Great idea!', m.getBody());

		// without quote and author
		final m = new Message('anna@example.com', 'yes').reply('x');
		equals('yes', m.body);
		equals('yes', m.getBody());
		isNull(m.getReply().to);
		isFalse(Fallback.has(m, MessageReply.XMLNS));
		isNull(new Message('anna@example.com', 'hi').getReply());

		// replying again replaces the mark (the quote stays in the body)
		m.reply('y').reply('z');
		equals(1, m.toXML().elements.named('reply').length);
		equals('z', m.getReply().id);
	}

	function test_fallback_code_points() {
		// offsets in code points: emojis outside the BMP count once
		final m = new Message('anna@example.com', '🙂 ok').reply('id', null, 'zwei 🙂\nZeile é');
		equals('> zwei 🙂\n> Zeile é\n🙂 ok', m.body);
		equals('19', m.toXML().elements.named('fallback')[0].firstElement.get('end'));
		equals('🙂 ok', (m.toString() : Message).getBody());
	}

	function test_parse() {
		// as https://xmpp.org/extensions/xep-0461.html#example-2
		final m = Message.fromString('<message to="anna@example.com" id="message-id3" type="chat">'
			+ '<body>> Anna wrote:\n> We should bake a cake\nGreat idea!</body>'
			+ '<reply to="anna@example.com/laptop" id="message-id1" xmlns="urn:xmpp:reply:0"/>'
			+ '<fallback xmlns="urn:xmpp:fallback:0" for="urn:xmpp:reply:0"><body start="0" end="38"/></fallback></message>');
		equals('message-id1', m.getReply().id);
		equals('Great idea!', m.getBody());

		// a fallback for another extension is kept, a fallback without range is the whole body
		function fallback(content:String):Message
			return Message.fromString('<message><body>> q\nhi</body><reply id="a" xmlns="urn:xmpp:reply:0"/>$content</message>');
		equals('> q\nhi', fallback('<fallback xmlns="urn:xmpp:fallback:0" for="urn:xmpp:other"><body start="0" end="4"/></fallback>').getBody());
		equals('', fallback('<fallback xmlns="urn:xmpp:fallback:0" for="urn:xmpp:reply:0"/>').getBody());
		// invalid ranges are ignored
		equals('> q\nhi', fallback('<fallback xmlns="urn:xmpp:fallback:0" for="urn:xmpp:reply:0"><body start="3" end="99"/></fallback>').getBody());
		equals('> q\nhi', fallback('<fallback xmlns="urn:xmpp:fallback:0" for="urn:xmpp:reply:0"><body start="x" end="2"/></fallback>').getBody());
		// several ranges
		equals('qi', fallback('<fallback xmlns="urn:xmpp:fallback:0" for="urn:xmpp:reply:0"><body start="0" end="2"/><body start="3" end="5"/></fallback>').getBody());
		isNull(new Message().getBody());
	}
}
