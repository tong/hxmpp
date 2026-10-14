import utest.Assert.*;
import xmpp.XML;

using xmpp.Oob;

class TestResultSet extends utest.Test {
	function test_result_set() {
		// https://xmpp.org/extensions/xep-0059.html#examples
		var xml = xmpp.ResultSet.create({max: 10});
		equals(xmpp.ResultSet.XMLNS, xml.get('xmlns'));
		equals('10', xml.elements.named('max')[0].text);
		equals(1, xml.elements.length);

		xml = xmpp.ResultSet.create({max: 10, after: 'peterpan@neverland.lit'});
		equals('peterpan@neverland.lit', xml.elements.named('after')[0].text);

		// last page: empty <before/>
		xml = xmpp.ResultSet.lastPage(10);
		equals(1, xml.elements.named('before').length);
		isNull(xml.elements.named('before')[0].text);

		xml = xmpp.ResultSet.create({max: 10, index: 371});
		equals('371', xml.elements.named('index')[0].text);
		equals('0', xmpp.ResultSet.create({max: 0}).elements.named('max')[0].text);

		final payload = XML.fromString('<query xmlns="jabber:iq:search"><item jid="stpeter@jabber.org"/><set xmlns="http://jabber.org/protocol/rsm"><first index="0">stpeter@jabber.org</first><last>peterpan@neverland.lit</last><count>800</count></set></query>');
		final page = xmpp.ResultSet.get(payload);
		equals('stpeter@jabber.org', page.first);
		equals(0, page.firstIndex);
		equals('peterpan@neverland.lit', page.last);
		equals(800, page.count);

		final next = xmpp.ResultSet.nextPage(page, 10);
		equals('peterpan@neverland.lit', next.elements.named('after')[0].text);
		final previous = xmpp.ResultSet.previousPage(page, 10);
		equals('stpeter@jabber.org', previous.elements.named('before')[0].text);

		// count only, no items
		final page = xmpp.ResultSet.parse(XML.fromString('<set xmlns="http://jabber.org/protocol/rsm"><count>800</count></set>'));
		equals(800, page.count);
		isNull(page.first);
		isNull(xmpp.ResultSet.nextPage(page, 10));

		isNull(xmpp.ResultSet.get(XML.fromString('<query xmlns="jabber:iq:search"/>')));
		isNull(xmpp.ResultSet.get(null));
	}
}
