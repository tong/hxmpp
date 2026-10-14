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
}
