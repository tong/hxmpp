import utest.Assert.*;
import xmpp.Message;

class TestCarbons extends StreamTest {
	function test_carbons() {
		xmpp.Carbons.enableMessageCarbons(stream, r -> {});
		equals('set', lastSent().get('type'));
		isNull(lastSent().get('to'));
		equals('enable', lastSent().firstElement.name);
		equals(xmpp.Carbons.XMLNS, lastSent().firstElement.get('xmlns'));

		@:privateAccess stream.jid = 'juliet@capulet.lit/balcony';
		function carbon(from:String, kind:String):Message
			return Message.fromString('<message from="$from" to="juliet@capulet.lit/balcony" type="chat">'
				+ '<$kind xmlns="urn:xmpp:carbons:2"><forwarded xmlns="urn:xmpp:forward:0">'
				+ '<message from="romeo@montague.lit/home" to="juliet@capulet.lit/chamber" type="chat"><body>Wherefore art thou?</body></message>'
				+ '</forwarded></$kind></message>');

		final c = xmpp.Carbons.getCarbon(stream, carbon('juliet@capulet.lit', 'received'));
		isFalse(c.sent);
		equals('romeo@montague.lit/home', c.message.from);
		equals('Wherefore art thou?', c.message.body);
		isTrue(xmpp.Carbons.getCarbon(stream, carbon('Juliet@Capulet.lit', 'sent')).sent);

		// forged or invalid copies are ignored
		isNull(xmpp.Carbons.getCarbon(stream, carbon('romeo@montague.lit', 'sent')));
		isNull(xmpp.Carbons.getCarbon(stream, carbon('romeo@montague.lit/home', 'received')));
		isNull(xmpp.Carbons.getCarbon(stream, carbon('juliet@capulet.lit/chamber', 'sent')));
		isNull(xmpp.Carbons.getCarbon(stream, Message.fromString('<message><sent xmlns="urn:xmpp:carbons:2"><forwarded xmlns="urn:xmpp:forward:0"><message><body>x</body></message></forwarded></sent></message>')));
		isNull(xmpp.Carbons.getCarbon(stream, Message.fromString('<message from="juliet@capulet.lit"><sent xmlns="urn:xmpp:carbons:2"/></message>')));
		isNull(xmpp.Carbons.getCarbon(stream, new Message('romeo@montague.lit', 'hi')));

		// unknown own jid (before resource binding)
		@:privateAccess stream.jid = null;
		isNull(xmpp.Carbons.getCarbon(stream, carbon('juliet@capulet.lit', 'received')));

		final m = xmpp.Carbons.makePrivate(xmpp.Carbons.makePrivate(new Message('romeo@montague.lit', 'secret')));
		final xml = m.toXML();
		equals(1, xml.elements.named('private').length);
		equals(xmpp.Carbons.XMLNS, xml.elements.named('private')[0].get('xmlns'));
		equals(1, xml.elements.named('no-copy').length);
		equals('urn:xmpp:hints', xml.elements.named('no-copy')[0].get('xmlns'));
	}
}
