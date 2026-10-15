import utest.Assert.*;
import xmpp.Message;
import xmpp.StanzaId;

using xmpp.StanzaId;

class TestStanzaId extends utest.Test {
	function test_stanza_id() {
		// https://xmpp.org/extensions/xep-0359.html#example-2
		final m = Message.fromString('<message from="coven@chat.shakespeare.lit/thirdwitch" type="groupchat"><body>hi</body>'
			+ '<stanza-id xmlns="urn:xmpp:sid:0" id="de305d54-75b4-431b-adb2-eb6b9e546013" by="Coven@chat.shakespeare.lit"/>'
			+ '<stanza-id xmlns="urn:xmpp:sid:0" id="forged" by="juliet@capulet.lit"/>'
			+ '<origin-id xmlns="urn:xmpp:sid:0" id="origin1"/></message>');
		equals('de305d54-75b4-431b-adb2-eb6b9e546013', m.getStanzaId('coven@chat.shakespeare.lit'));
		equals('forged', m.getStanzaId('juliet@capulet.lit'));
		isNull(m.getStanzaId('romeo@montague.lit'));
		isNull(m.getStanzaId(null));
		equals('origin1', m.getOriginId());
	}

	function test_origin_id() {
		final m = new Message('romeo@montague.lit', 'hi').setOriginId();
		notNull(m.id);
		equals(m.id, m.getOriginId());
		m.setOriginId('other');
		equals('other', m.getOriginId());
		equals(1, m.toXML().elements.named('origin-id').length);
		isNull(new Message().getOriginId());
	}
}
