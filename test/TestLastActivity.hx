import utest.Assert.*;
import xmpp.Response;
import xmpp.XML;

using xmpp.Oob;

class TestLastActivity extends StreamTest {
	function test_last_activity() {
		var response:Response<XML> = null;
		var iq = xmpp.LastActivity.getLastActivity(stream, r -> response = r);
		equals('example.com', lastSent().get('to'));
		equals(xmpp.LastActivity.XMLNS, lastSent().firstElement.get('xmlns'));

		// https://xmpp.org/extensions/xep-0012.html#offline
		iq = xmpp.LastActivity.getLastActivity(stream, 'juliet@capulet.com', r -> response = r);
		stream.recv('<iq type="result" id="${iq.id}" from="juliet@capulet.com"><query xmlns="jabber:iq:last" seconds="903">Heading Home</query></iq>');
		final last = xmpp.LastActivity.parse(response.payload);
		equals(903, last.seconds);
		equals('Heading Home', last.status);

		final last = xmpp.LastActivity.parse(XML.fromString('<query xmlns="jabber:iq:last" seconds="123"/>'));
		equals(123, last.seconds);
		isNull(last.status);
		isNull(xmpp.LastActivity.parse(XML.fromString('<query xmlns="jabber:iq:last"/>')));
		isNull(xmpp.LastActivity.parse(XML.fromString('<query xmlns="jabber:iq:last" seconds="x"/>')));
	}

	function test_last_activity_requests() {
		xmpp.LastActivity.handleRequests(stream, () -> 42);
		stream.recv('<iq type="get" id="l1" from="romeo@montague.net/orchard"><query xmlns="jabber:iq:last"/></iq>');
		equals('result', lastSent().get('type'));
		equals('l1', lastSent().get('id'));
		equals(42, xmpp.LastActivity.parse(lastSent().firstElement).seconds);
	}
}
