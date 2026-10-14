import utest.Assert.*;
import xmpp.XML;

using xmpp.Oob;

class TestServiceDiscovery extends StreamTest {
	function test_disco_parse() {
		// https://xmpp.org/extensions/xep-0030.html#info-basic
		final info = xmpp.ServiceDiscovery.parseInfo(XML.fromString('<query xmlns="http://jabber.org/protocol/disco#info">
			<identity category="conference" type="text" name="Play-Specific Chatrooms"/>
			<identity category="directory" type="chatroom" name="Play-Specific Chatrooms"/>
			<feature var="http://jabber.org/protocol/disco#info"/>
			<feature var="http://jabber.org/protocol/disco#items"/>
			<feature var="http://jabber.org/protocol/muc"/>
			<feature var="jabber:iq:register"/>
			<feature var="jabber:iq:search"/>
			<feature var="jabber:iq:time"/>
			<feature var="jabber:iq:version"/>
			<x xmlns="jabber:x:data" type="result"><field var="FORM_TYPE" type="hidden"><value>urn:xmpp:http:upload:0</value></field><field var="max-file-size"><value>5242880</value></field></x>
		</query>'));
		equals(2, info.identities.length);
		equals('conference', info.identities[0].category);
		equals('text', info.identities[0].type);
		equals('Play-Specific Chatrooms', info.identities[0].name);
		equals(7, info.features.length);
		isTrue(xmpp.ServiceDiscovery.hasFeature(info, 'http://jabber.org/protocol/muc'));
		isFalse(xmpp.ServiceDiscovery.hasFeature(info, 'urn:xmpp:ping'));
		equals(1, info.forms.length);
		equals('5242880', info.forms[0].getValue('max-file-size'));

		// https://xmpp.org/extensions/xep-0030.html#items-basic
		final items = xmpp.ServiceDiscovery.parseItems(XML.fromString('<query xmlns="http://jabber.org/protocol/disco#items">
			<item jid="people.shakespeare.lit" name="Directory of Characters"/>
			<item jid="catalog.shakespeare.lit" node="books" name="Books by and about Shakespeare"/>
			<item name="no jid"/>
		</query>'));
		equals(2, items.length);
		equals('people.shakespeare.lit', items[0].jid);
		isNull(items[0].node);
		equals('books', items[1].node);
		equals('Books by and about Shakespeare', items[1].name);
	}

	function test_disco_requests() {
		xmpp.ServiceDiscovery.handleRequests(stream, {category: 'client', type: 'pc', name: 'hxmpp'}, [xmpp.ChatState.XMLNS]);
		// handlers registered later are advertised too
		xmpp.Ping.handleRequests(stream);

		stream.recv('<iq type="get" id="d1" from="romeo@montague.net/orchard"><query xmlns="http://jabber.org/protocol/disco#info"/></iq>');
		equals('result', lastSent().get('type'));
		final info = xmpp.ServiceDiscovery.parseInfo(lastSent().firstElement);
		equals('client', info.identities[0].category);
		equals('pc', info.identities[0].type);
		equals('hxmpp', info.identities[0].name);
		equals([
			xmpp.ChatState.XMLNS,
			xmpp.ServiceDiscovery.XMLNS_INFO,
			xmpp.ServiceDiscovery.XMLNS_ITEMS,
			xmpp.Ping.XMLNS
		].join(','), info.features.join(','));

		stream.recv('<iq type="get" id="d2" from="romeo@montague.net/orchard"><query xmlns="http://jabber.org/protocol/disco#info" node="x"/></iq>');
		equals('item-not-found', lastSent().elements.named('error')[0].firstElement.name);

		stream.recv('<iq type="get" id="d3" from="romeo@montague.net/orchard"><query xmlns="http://jabber.org/protocol/disco#items"/></iq>');
		equals('result', lastSent().get('type'));
		equals(xmpp.ServiceDiscovery.XMLNS_ITEMS, lastSent().firstElement.get('xmlns'));
		equals(0, lastSent().firstElement.elements.length);
	}
}
