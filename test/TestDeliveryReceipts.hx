import utest.Assert.*;
import xmpp.Message;

using xmpp.DeliveryReceipts;

class TestDeliveryReceipts extends StreamTest {
	function test_delivery_receipts() {
		// https://xmpp.org/extensions/xep-0184.html#protocol
		final m = new Message('northumberland@shakespeare.lit/westminster', 'My lord, dispatch; read o\'er these articles.').requestReceipt();
		notNull(m.id);
		m.requestReceipt();
		final xml = m.toXML();
		equals(1, xml.elements.named('request').length);
		equals(xmpp.DeliveryReceipts.XMLNS, xml.elements.named('request')[0].get('xmlns'));
		final own = new Message('romeo@example.net', 'hi');
		own.id = 'own';
		equals('own', own.requestReceipt().id);

		final received = Message.fromString('<message from="kingrichard@royalty.england.lit/throne" id="bi29sg183b4v" to="northumberland@shakespeare.lit/westminster" type="chat"><body>My lord, dispatch; read o\'er these articles.</body><request xmlns="urn:xmpp:receipts"/></message>');
		isTrue(received.wantsReceipt());
		final receipt = received.createReceipt();
		equals('kingrichard@royalty.england.lit/throne', receipt.to);
		equals(chat, receipt.type);
		notNull(receipt.id);
		isNull(receipt.body);
		final xml = receipt.toXML();
		equals(1, [for (e in xml.elements) e].length);
		equals('bi29sg183b4v', xml.elements.named('received')[0].get('id'));
		// a receipt does not request a receipt
		isFalse(receipt.wantsReceipt());
		equals(receipt, receipt.requestReceipt());
		isNull(receipt.toXML().elements.named('request')[0]);

		final parsed:Message = receipt.toString();
		equals('bi29sg183b4v', parsed.receipt());
		isNull(received.receipt());

		// no receipt without id, for errors, or without request
		isFalse(Message.fromString('<message from="a@example.net/r"><request xmlns="urn:xmpp:receipts"/></message>').wantsReceipt());
		isNull(Message.fromString('<message from="a@example.net/r" id="1" type="error"><request xmlns="urn:xmpp:receipts"/></message>').createReceipt());
		isNull(Message.fromString('<message from="a@example.net/r" id="1"><body>hi</body></message>').createReceipt());
		isFalse(new Message('a@example.net', 'x', null, error).requestReceipt().wantsReceipt());

		// groupchat: sent to the room
		final r = Message.fromString('<message from="room@muc.example.net/romeo" id="g1" type="groupchat"><body>hi</body><request xmlns="urn:xmpp:receipts"/></message>').createReceipt();
		equals('room@muc.example.net', r.to);
		equals(groupchat, r.type);
	}
}
