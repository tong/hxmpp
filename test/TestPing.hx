import utest.Assert.*;
import xmpp.Response;
import xmpp.XML;

using xmpp.Oob;

class TestPing extends StreamTest {
	function test_ping() {
		// https://xmpp.org/extensions/xep-0199.html#c2s
		var response:Response<XML> = null;
		var iq = xmpp.Ping.ping(stream, r -> response = r);
		equals('get', lastSent().get('type'));
		isNull(lastSent().get('to'));
		equals('ping', lastSent().firstElement.name);
		equals(xmpp.Ping.XMLNS, lastSent().firstElement.get('xmlns'));
		stream.recv('<iq type="result" id="${iq.id}" from="example.com"/>');
		isTrue(response.ok());

		iq = xmpp.Ping.ping(stream, 'juliet@capulet.lit/balcony');
		equals('juliet@capulet.lit/balcony', lastSent().get('to'));
		// a response without handler is ignored
		final count = sent.length;
		stream.recv('<iq type="result" id="${iq.id}" from="juliet@capulet.lit/balcony"/>');
		equals(count, sent.length);
	}

	function test_ping_requests() {
		// not answered: service-unavailable
		stream.recv('<iq type="get" id="p1" from="example.com"><ping xmlns="urn:xmpp:ping"/></iq>');
		equals('error', lastSent().get('type'));

		xmpp.Ping.handleRequests(stream);
		stream.recv('<iq type="get" id="p2" from="example.com"><ping xmlns="urn:xmpp:ping"/></iq>');
		equals('result', lastSent().get('type'));
		equals('p2', lastSent().get('id'));
		equals('example.com', lastSent().get('to'));
		equals(0, lastSent().elements.length);
	}
}
