import utest.Assert.*;
import xmpp.Response;
import xmpp.XML;

using xmpp.Oob;

class TestEntityTime extends StreamTest {
	function test_entity_time() {
		var response:Response<XML> = null;
		final iq = xmpp.EntityTime.getEntityTime(stream, 'juliet@capulet.com/balcony', r -> response = r);
		equals('time', lastSent().firstElement.name);
		equals(xmpp.EntityTime.XMLNS, lastSent().firstElement.get('xmlns'));
		// https://xmpp.org/extensions/xep-0202.html#protocol
		stream.recv('<iq type="result" id="${iq.id}" from="juliet@capulet.com/balcony"><time xmlns="urn:xmpp:time"><tzo>-06:00</tzo><utc>2006-12-19T17:58:35Z</utc></time></iq>');
		final t = xmpp.EntityTime.parse(response.payload);
		equals('-06:00', t.tzo);
		equals('2006-12-19T17:58:35Z', t.utc);
		equals(-360, t.offset);
		equals(1166551115000.0, t.date.getTime());

		isNull(xmpp.EntityTime.parse(XML.fromString('<time xmlns="urn:xmpp:time"><utc>2006-12-19T17:58:35Z</utc></time>')));
		final t = xmpp.EntityTime.parse(XML.fromString('<time xmlns="urn:xmpp:time"><tzo>bad</tzo><utc>bad</utc></time>'));
		isNull(t.offset);
		isNull(t.date);

		equals(0, xmpp.EntityTime.parseOffset('Z'));
		equals(330, xmpp.EntityTime.parseOffset('+05:30'));
		equals(-60, xmpp.EntityTime.parseOffset('-01:00'));
		isNull(xmpp.EntityTime.parseOffset('0530'));
		equals('Z', xmpp.EntityTime.formatOffset(0));
		equals('+05:30', xmpp.EntityTime.formatOffset(330));
		equals('-06:00', xmpp.EntityTime.formatOffset(-360));
	}

	function test_entity_time_requests() {
		xmpp.EntityTime.handleRequests(stream);
		stream.recv('<iq type="get" id="t1" from="romeo@montague.net/orchard"><time xmlns="urn:xmpp:time"/></iq>');
		final iq = lastSent();
		equals('result', iq.get('type'));
		equals('t1', iq.get('id'));
		final t = xmpp.EntityTime.parse(iq.firstElement);
		notNull(t.date);
		isTrue(Math.abs(t.date.getTime() - Date.now().getTime()) < 5000);
		equals(-Date.now().getTimezoneOffset(), t.offset);
	}
}
