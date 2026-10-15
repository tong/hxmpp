import utest.Assert.*;
import xmpp.Message;
import xmpp.MessageReactions;

using xmpp.MessageReactions;

class TestMessageReactions extends utest.Test {
	function test_react() {
		final m = new Message('romeo@example.net').react('744f6e18-a57a-11e9-a656-4889e7820c76', ['👋', '🐢', '👋', ' ', '']);
		final xml = m.toXML();
		final reactions = xml.elements.named('reactions')[0];
		equals(MessageReactions.XMLNS, reactions.get('xmlns'));
		equals('744f6e18-a57a-11e9-a656-4889e7820c76', reactions.get('id'));
		equals(2, reactions.elements.named('reaction').length);
		equals('👋', reactions.elements.named('reaction')[0].text);
		equals(1, xml.elements.named('store').length);
		isNull(xml.elements.named('body')[0]);
		notNull(m.id);

		// parsed back
		final r = (m.toString() : Message).getReactions();
		equals('744f6e18-a57a-11e9-a656-4889e7820c76', r.id);
		same(['👋', '🐢'], r.reactions);

		// reacting again replaces the reactions, one storage hint
		m.react('744f6e18-a57a-11e9-a656-4889e7820c76', []);
		equals(1, m.toXML().elements.named('reactions').length);
		equals(1, m.toXML().elements.named('store').length);
		same([], m.getReactions().reactions);
		isNull(new Message('romeo@example.net', 'hi').getReactions());
	}

	function test_parse() {
		// https://xmpp.org/extensions/xep-0444.html#example-2
		final m = Message.fromString('<message to="romeo@capulet.net/orchard" id="96d73204-a57a-11e9-88b8-4889e7820c76" type="chat">'
			+ '<reactions id="744f6e18-a57a-11e9-a656-4889e7820c76" xmlns="urn:xmpp:reactions:0">'
			+ '<reaction>👋</reaction><reaction>🐢</reaction><reaction>🐢</reaction><reaction></reaction></reactions>'
			+ '<store xmlns="urn:xmpp:hints"/></message>');
		final r = m.getReactions();
		equals('744f6e18-a57a-11e9-a656-4889e7820c76', r.id);
		same(['👋', '🐢'], r.reactions);
		// without id: invalid
		isNull(Message.fromString('<message><reactions xmlns="urn:xmpp:reactions:0"><reaction>👋</reaction></reactions></message>').getReactions());
	}
}
