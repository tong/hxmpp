import utest.Assert.*;
import xmpp.Message;
import xmpp.XML;

class TestPubSub extends StreamTest {
	function test_pubsub_requests() {
		final service = 'pubsub.example.com';
		function pubsub():XML
			return lastSent().firstElement;

		xmpp.PubSub.retractItem(stream, service, 'news', 'item1', r -> {});
		equals('set', lastSent().get('type'));
		equals(service, lastSent().get('to'));
		equals('item1', pubsub().firstElement.firstElement.get('id'));

		xmpp.PubSub.publish(stream, service, 'news', XML.create('item').set('id', 'x'), r -> {});
		equals(service, lastSent().get('to'));
		equals(xmpp.PubSub.XMLNS, pubsub().get('xmlns'));

		// subscriber jid defaults to the own bare jid
		@:privateAccess stream.jid = 'juliet@example.com/balcony';
		xmpp.PubSub.subscribe(stream, service, 'news', r -> {});
		equals('juliet@example.com', pubsub().firstElement.get('jid'));
		xmpp.PubSub.subscribe(stream, service, 'news', 'juliet@example.com/balcony', r -> {});
		equals('juliet@example.com/balcony', pubsub().firstElement.get('jid'));
		xmpp.PubSub.unsubscribe(stream, service, 'news', r -> {});
		equals('juliet@example.com', pubsub().firstElement.get('jid'));
		isNull(pubsub().firstElement.get('subid'));
		xmpp.PubSub.unsubscribe(stream, service, 'news', null, 'sub1', r -> {});
		equals('juliet@example.com', pubsub().firstElement.get('jid'));
		equals('sub1', pubsub().firstElement.get('subid'));

		// owner use cases
		xmpp.PubSub.deleteNode(stream, service, 'news', r -> {});
		equals(xmpp.PubSub.XMLNS_OWNER, pubsub().get('xmlns'));
		equals('delete', pubsub().firstElement.name);
		xmpp.PubSub.purgeItems(stream, service, 'news', r -> {});
		equals(xmpp.PubSub.XMLNS_OWNER, pubsub().get('xmlns'));
		xmpp.PubSub.setAffiliation(stream, service, 'news', {jid: 'romeo@example.net', affiliation: publish_only}, r -> {});
		equals(xmpp.PubSub.XMLNS_OWNER, pubsub().get('xmlns'));
		equals('publish-only', pubsub().firstElement.firstElement.get('affiliation'));

		// optional node
		xmpp.PubSub.getSubscriptions(stream, service, r -> {});
		equals(xmpp.PubSub.XMLNS, pubsub().get('xmlns'));
		isFalse(pubsub().firstElement.has('node'));
		xmpp.PubSub.getSubscriptions(stream, service, 'news', r -> {});
		equals('news', pubsub().firstElement.get('node'));
	}

	function test_pubsub_events() {
		function event(xml:String):Null<xmpp.PubSub.PubSubEvent>
			return xmpp.PubSub.getEvent(Message.fromString('<message from="pubsub.example.com"><event xmlns="http://jabber.org/protocol/pubsub#event">$xml</event></message>'));

		switch event('<items node="news"><item id="a"><entry xmlns="http://www.w3.org/2005/Atom"><title>Hi</title></entry></item><item id="b"/><retract id="c"/></items>') {
			case Items(node, items, retracted):
				equals('news', node);
				equals(2, items.length);
				equals('a', items[0].get('id'));
				equals('entry', items[0].firstElement.name);
				equals('c', retracted.join(','));
			case e: fail('unexpected $e');
		}
		switch event('<delete node="news"><redirect uri="xmpp:pubsub.example.com?;node=news2"/></delete>') {
			case Delete(node, redirect):
				equals('news', node);
				equals('xmpp:pubsub.example.com?;node=news2', redirect);
			case e: fail('unexpected $e');
		}
		switch event('<purge node="news"/>') {
			case Purge(node): equals('news', node);
			case e: fail('unexpected $e');
		}
		switch event('<configuration node="news"><x xmlns="jabber:x:data" type="result"><field var="pubsub#title"><value>News</value></field></x></configuration>') {
			case Configuration(node, form):
				equals('news', node);
				equals('News', form.fields[0].values[0]);
			case e: fail('unexpected $e');
		}
		switch event('<subscription node="news" jid="romeo@example.net" subscription="subscribed"/>') {
			case Subscription(node, jid, subscription):
				equals('romeo@example.net', jid);
				equals(xmpp.PubSub.SubscriptionState.subscribed, subscription);
			case e: fail('unexpected $e');
		}
		isNull(xmpp.PubSub.getEvent(new Message('romeo@example.net', 'hi')));
	}
	function test_pubsub_owner() {
		final service = 'pubsub.example.com';
		function pubsub():XML
			return lastSent().firstElement;

		xmpp.PubSub.createConfiguredNode(stream, service, 'doc', ['pubsub#access_model' => 'whitelist'], r -> {});
		equals('set', lastSent().get('type'));
		equals(xmpp.PubSub.XMLNS, pubsub().get('xmlns'));
		equals('doc', pubsub().elements.named('create')[0].get('node'));
		final form = xmpp.DataForm.fromXML(pubsub().elements.named('configure')[0].firstElement);
		equals('submit', form.type);
		equals('http://jabber.org/protocol/pubsub#node_config', form.fields.filter(f -> f.variable == 'FORM_TYPE')[0].values[0]);
		equals('whitelist', form.fields.filter(f -> f.variable == 'pubsub#access_model')[0].values[0]);

		xmpp.PubSub.getNodeAffiliations(stream, service, 'doc', r -> {});
		equals('get', lastSent().get('type'));
		equals(xmpp.PubSub.XMLNS_OWNER, pubsub().get('xmlns'));
		equals('affiliations', pubsub().firstElement.name);

		xmpp.PubSub.getNodeSubscriptions(stream, service, 'doc', r -> {});
		equals(xmpp.PubSub.XMLNS_OWNER, pubsub().get('xmlns'));
		equals('subscriptions', pubsub().firstElement.name);

		xmpp.PubSub.setSubscription(stream, service, 'doc', 'romeo@example.net/orchard', none, r -> {});
		equals('set', lastSent().get('type'));
		equals(xmpp.PubSub.XMLNS_OWNER, pubsub().get('xmlns'));
		final sub = pubsub().firstElement.firstElement;
		equals('romeo@example.net/orchard', sub.get('jid'));
		equals('none', sub.get('subscription'));
	}

	function test_pubsub_parse() {
		final affs = xmpp.PubSub.parseAffiliations(XML.fromString('<pubsub xmlns="http://jabber.org/protocol/pubsub#owner"><affiliations node="doc">'
			+ '<affiliation jid="juliet@example.com" affiliation="owner"/><affiliation jid="romeo@example.net" affiliation="publisher"/>'
			+ '</affiliations></pubsub>'));
		equals(2, affs.length);
		equals('romeo@example.net', affs[1].jid);
		equals(xmpp.PubSub.AffiliationState.publisher, affs[1].affiliation);
		equals('doc', affs[1].node);

		final subs = xmpp.PubSub.parseSubscriptions(XML.fromString('<pubsub xmlns="http://jabber.org/protocol/pubsub#owner"><subscriptions node="doc">'
			+ '<subscription jid="romeo@example.net/orchard" subscription="subscribed" subid="s1"/></subscriptions></pubsub>'));
		equals(1, subs.length);
		equals('romeo@example.net/orchard', subs[0].jid);
		equals(xmpp.PubSub.SubscriptionState.subscribed, subs[0].subscription);
		equals('s1', subs[0].subid);
		equals('doc', subs[0].node);

		final items = xmpp.PubSub.parseItems(XML.fromString('<pubsub xmlns="http://jabber.org/protocol/pubsub"><items node="doc">'
			+ '<item id="a" publisher="juliet@example.com"><op xmlns="urn:example"/></item><item id="b"/></items></pubsub>'));
		equals('a,b', items.map(i -> i.get('id')).join(','));
		equals('juliet@example.com', items[0].get('publisher'));

		equals(0, xmpp.PubSub.parseItems(null).length);
		equals(0, xmpp.PubSub.parseAffiliations(null).length);
		equals(0, xmpp.PubSub.parseSubscriptions(XML.fromString('<pubsub xmlns="http://jabber.org/protocol/pubsub"/>')).length);
	}
}
