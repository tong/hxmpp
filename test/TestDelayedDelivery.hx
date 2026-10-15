import utest.Assert.*;
import xmpp.Message;

using xmpp.DelayedDelivery;

class TestDelayedDelivery extends utest.Test {
	function test_delay() {
		// https://xmpp.org/extensions/xep-0203.html#examples
		final m = Message.fromString('<message from="romeo@montague.net/orchard" to="juliet@capulet.com" type="chat"><body>O blessed, blessed night!</body><delay xmlns="urn:xmpp:delay" from="capulet.com" stamp="2002-09-10T23:08:25Z">Offline Storage</delay></message>');
		final d = m.delay();
		equals('capulet.com', d.from);
		equals('2002-09-10T23:08:25Z', d.stamp);
		equals('Offline Storage', d.description);
		equals(1031699305000.0, d.date.getTime());

		final p = xmpp.Presence.fromString('<presence from="juliet@capulet.com/balcony"><status>anon!</status><delay xmlns="urn:xmpp:delay" stamp="2002-09-10T23:41:07Z"/></presence>');
		final d = p.delay();
		isNull(d.from);
		isNull(d.description);
		equals('2002-09-10T23:41:07Z', d.stamp);

		isNull(new Message('a@b', 'hi').delay());
		// no stamp, or other element in the namespace
		isNull(Message.fromString('<message><delay xmlns="urn:xmpp:delay" from="x"/></message>').delay());
		isNull(Message.fromString('<message><other xmlns="urn:xmpp:delay" stamp="2002-09-10T23:41:07Z"/></message>').delay());
	}

	function test_delay_stamp() {
		final parse = xmpp.DelayedDelivery.parseStamp;
		equals(0.0, parse('1970-01-01T00:00:00Z').getTime());
		equals(1031699305000.0, parse('2002-09-10T23:08:25Z').getTime());
		#if !(hl || neko) // hashlink and neko dates have second resolution
		equals(1031699305123.0, parse('2002-09-10T23:08:25.123Z').getTime());
		#end
		equals(1031699305000.0, parse('2002-09-11T01:08:25+02:00').getTime());
		equals(1031699305000.0, parse('2002-09-10T18:08:25-05:00').getTime());
		equals(951782400000.0, parse('2000-02-29T00:00:00Z').getTime());
		#if !hl // hashlink dates before 1970 are not supported
		equals(-86400000.0, parse('1969-12-31T00:00:00Z').getTime());
		#end
		isNull(parse('2002-09-10 23:08:25'));
		isNull(parse('20020910T23:08:25'));
		isNull(parse(null));

		final date = Date.fromTime(1031699305000.0);
		equals('2002-09-10T23:08:25Z', xmpp.DelayedDelivery.formatStamp(date));
		final xml = xmpp.DelayedDelivery.createDelay(date, 'capulet.com', 'Offline Storage');
		equals(xmpp.DelayedDelivery.XMLNS, xml.get('xmlns'));
		equals('capulet.com', xml.get('from'));
		equals('2002-09-10T23:08:25Z', xml.get('stamp'));
		equals('Offline Storage', xml.text);
		isFalse(xmpp.DelayedDelivery.createDelay(date).has('from'));
	}
}
