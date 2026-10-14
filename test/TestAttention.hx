import utest.Assert.*;
import xmpp.Message;

using xmpp.Attention;

class TestAttention extends utest.Test {
	function test_attention() {
		final m = new Message('romeo@example.net/orchard').captureAttention();
		equals(headline, m.type);
		m.captureAttention();
		final xml = m.toXML();
		equals(1, xml.elements.named('attention').length);
		equals(xmpp.Attention.XMLNS, xml.elements.named('attention')[0].get('xmlns'));
		isTrue(Message.fromString(xml.toString()).wantsAttention());

		isFalse(new Message('romeo@example.net', 'hi').wantsAttention());
		// other elements in the namespace are no request
		isFalse(Message.fromString('<message><other xmlns="urn:xmpp:attention:0"/></message>').wantsAttention());
		// delayed requests are ignored
		isFalse(Message.fromString('<message type="headline"><attention xmlns="urn:xmpp:attention:0"/><delay xmlns="urn:xmpp:delay" stamp="2026-10-12T10:00:00Z"/></message>')
			.wantsAttention());
	}
}
