import utest.Assert.*;
import xmpp.XML;
import xmpp.Presence.Subscription;
import xmpp.client.Roster;

using xmpp.client.Nickname;
using xmpp.client.Roster;

class TestClientRoster extends utest.Test {
	var stream:xmpp.client.Stream;
	var sent:Array<String>;

	function setup() {
		sent = [];
		stream = new xmpp.client.Stream('example.com');
		stream.output = str -> sent.push(str);
		stream.start(features -> {});
		stream.recv("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='abc' from='example.com' version='1.0'><stream:features></stream:features>");
		@:privateAccess stream.jid = 'juliet@example.com/balcony';
	}

	function lastSent():XML
		return XML.fromString(sent[sent.length - 1]);

	function test_subscription() {
		final p = stream.subscribePresence('romeo@example.net');
		var x = lastSent();
		equals('presence', x.name);
		equals('romeo@example.net', x.get('to'));
		equals('subscribe', x.get('type'));
		equals(p.id, x.get('id'));
		isNull(p.getNickname());

		stream.subscribePresence('romeo@example.net', 'Juliet');
		equals('Juliet', xmpp.Presence.fromXML(lastSent()).getNickname());

		stream.unsubscribePresence('romeo@example.net');
		equals('unsubscribe', lastSent().get('type'));
		stream.approveSubscription('romeo@example.net');
		equals('subscribed', lastSent().get('type'));
		equals('romeo@example.net', lastSent().get('to'));
		stream.cancelSubscription('romeo@example.net');
		equals('unsubscribed', lastSent().get('type'));
	}

	function test_load() {
		stream.loadRoster(r -> {});
		var query = lastSent().firstElement;
		equals('get', lastSent().get('type'));
		equals(Roster.XMLNS, query.get('xmlns'));
		isNull(query.get('ver'));

		// https://xmpp.org/rfcs/rfc6121.html#roster-versioning-request
		stream.loadRoster('ver14', r -> {});
		equals('ver14', lastSent().firstElement.get('ver'));
		stream.loadRoster('', r -> {});
		equals('', lastSent().firstElement.get('ver'));
	}

	function test_versioning_offered() {
		isFalse(Roster.isVersioningOffered(null));
		isFalse(Roster.isVersioningOffered(XML.fromString("<stream:features xmlns:stream='http://etherx.jabber.org/streams'/>")));
		isTrue(Roster.isVersioningOffered(XML.fromString("<stream:features xmlns:stream='http://etherx.jabber.org/streams'><ver xmlns='urn:xmpp:features:rosterver'/></stream:features>")));
	}

	function test_parse() {
		// https://xmpp.org/rfcs/rfc6121.html#roster-login
		final roster = Roster.parseRoster(XML.fromString("<query xmlns='jabber:iq:roster' ver='ver11'>
			<item jid='romeo@example.net' name='Romeo' subscription='both'><group>Friends</group></item>
			<item jid='mercutio@example.com' name='Mercutio' subscription='from'/>
			<item jid='benvolio@example.net' name='Benvolio' subscription='none' ask='subscribe' approved='true'><group>A</group><group>B</group><group>A</group><group/></item>
			<item name='no jid'/>
		</query>"));
		equals('ver11', roster.ver);
		equals(3, roster.items.length);
		final romeo = roster.items[0];
		equals('romeo@example.net', romeo.jid);
		equals('Romeo', romeo.name);
		equals(Subscription.both, romeo.subscription);
		isNull(romeo.ask);
		isNull(romeo.approved);
		same(['Friends'], romeo.groups);
		equals(Subscription.from, roster.items[1].subscription);
		same([], roster.items[1].groups);
		final benvolio = roster.items[2];
		equals(Subscription.none, benvolio.subscription);
		equals(AskType.subscribe, benvolio.ask);
		isTrue(benvolio.approved);
		same(['A', 'B'], benvolio.groups);

		final empty = Roster.parseRoster(XML.fromString("<query xmlns='jabber:iq:roster'/>"));
		isNull(empty.ver);
		equals(0, empty.items.length);
		isNull(Roster.parseItem(XML.fromString("<item jid='a@b'/>")).name);
	}

	function test_add_remove() {
		// https://xmpp.org/rfcs/rfc6121.html#roster-add
		stream.addRosterItem('nurse@example.com', 'Nurse', ['Servants', '', 'Servants'], r -> {});
		final item = lastSent().firstElement.firstElement;
		equals('set', lastSent().get('type'));
		equals('nurse@example.com', item.get('jid'));
		equals('Nurse', item.get('name'));
		equals(1, item.elements.length);
		equals('Servants', item.firstElement.text);
		isNull(item.get('subscription'));

		stream.addRosterItem('nurse@example.com', r -> {});
		final item = lastSent().firstElement.firstElement;
		isNull(item.get('name'));
		equals(0, item.elements.length);

		// https://xmpp.org/rfcs/rfc6121.html#roster-delete
		stream.removeRosterItem('nurse@example.com', r -> {});
		final item = lastSent().firstElement.firstElement;
		equals('nurse@example.com', item.get('jid'));
		equals('remove', item.get('subscription'));
	}

	function test_push() {
		final pushes = new Array<{item:RosterItem, ver:Null<String>}>();
		Roster.handleRequests(stream, (item, ver) -> pushes.push({item: item, ver: ver}));

		// https://xmpp.org/rfcs/rfc6121.html#roster-add-success
		stream.recv("<iq id='a78b4q6ha463' to='juliet@example.com/balcony' type='set'><query xmlns='jabber:iq:roster' ver='ver13'><item jid='nurse@example.com' name='Nurse' subscription='none'><group>Servants</group></item></query></iq>");
		equals(1, pushes.length);
		equals('nurse@example.com', pushes[0].item.jid);
		same(['Servants'], pushes[0].item.groups);
		equals('ver13', pushes[0].ver);
		equals('result', lastSent().get('type'));
		equals('a78b4q6ha463', lastSent().get('id'));
		isNull(lastSent().firstElement);

		// from the user's bare jid
		stream.recv("<iq id='p2' from='Juliet@example.com' type='set'><query xmlns='jabber:iq:roster'><item jid='nurse@example.com' subscription='remove'/></query></iq>");
		equals(2, pushes.length);
		equals(Subscription.remove, pushes[1].item.subscription);
		isNull(pushes[1].ver);
		equals('result', lastSent().get('type'));

		// https://xmpp.org/rfcs/rfc6121.html#roster-syntax-actions-push (spoofed push)
		stream.recv("<iq id='p3' from='mallory@evil.example' type='set'><query xmlns='jabber:iq:roster'><item jid='mallory@evil.example' subscription='both'/></query></iq>");
		equals(2, pushes.length);
		equals('error', lastSent().get('type'));
		equals('p3', lastSent().get('id'));
		notNull(lastSent().elements.named('error')[0].elements.named('service-unavailable')[0]);

		// more than one item
		stream.recv("<iq id='p4' type='set'><query xmlns='jabber:iq:roster'><item jid='a@b'/><item jid='c@d'/></query></iq>");
		equals(2, pushes.length);
		notNull(lastSent().elements.named('error')[0].elements.named('bad-request')[0]);
	}
}
