import utest.Assert.*;
import xmpp.IQ;
import xmpp.Message;
import xmpp.Response;
import xmpp.URI;
import xmpp.XML;

using xmpp.ChatState;
using xmpp.HttpFileUpload;
using xmpp.LastMessageCorrection;
using xmpp.Oob;

class TestExtensions extends utest.Test {
	function test_last_message_correction() {
		final m = new Message('romeo@example.net', 'fixed').correct('msg42');
		final replace = m.toXML().elements.named('replace')[0];
		equals(LastMessageCorrection.XMLNS, replace.get('xmlns'));
		equals('msg42', replace.get('id'));

		final m:Message = m.toString();
		equals('msg42', m.correction());
		isNull(new Message('romeo@example.net', 'hi').correction());
	}

	function test_http_upload_slot() {
		final stream = new xmpp.client.Stream('example.com');
		final sent = new Array<String>();
		stream.output = str -> sent.push(str);
		final req:IQ = '<iq type="get" id="s1" from="romeo@example.net/orchard"><request xmlns="urn:xmpp:http:upload:0" filename="a.jpg" size="23456"/></iq>';
		stream.sendHttpUploadSlot(req, 'https://upload.example.com/put', 'https://download.example.com/get', ['Authorization' => 'Basic Base64String==']);
		final iq = XML.parse(sent[0]).firstElement;
		equals('result', iq.get('type'));
		equals('romeo@example.net/orchard', iq.get('to'));
		final slot = iq.firstElement;
		final put = slot.elements.named('put')[0];
		equals('https://upload.example.com/put', put.get('url'));
		final header = put.elements.named('header')[0];
		equals('Authorization', header.get('name'));
		equals('Basic Base64String==', header.text);
		equals('https://download.example.com/get', slot.elements.named('get')[0].get('url'));
	}

	var stream:xmpp.client.Stream;
	var sent:Array<String>;

	function setup() {
		sent = [];
		stream = new xmpp.client.Stream('example.com');
		stream.output = str -> sent.push(str);
		stream.start(features -> {});
		stream.recv("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='abc' from='example.com' version='1.0'><stream:features></stream:features>");
	}

	function lastSent():XML
		return XML.parse(sent[sent.length - 1]).firstElement;

	function test_pep() {
		equals('http://jabber.org/protocol/mood', xmpp.Pep.XMLNS_MOOD);
		equals('http://jabber.org/protocol/tune', xmpp.Pep.XMLNS_TUNE);
		xmpp.Pep.publishActivity(stream, relaxing, r -> {});
		final publish = lastSent().firstElement.firstElement;
		equals('publish', publish.name);
		equals(xmpp.Pep.XMLNS_ACTIVITY, publish.get('node'));
		isNull(publish.get('xmlns'));
	}

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

	function test_oob() {
		equals('jabber:iq:oob', xmpp.Oob.XMLNS);
		equals('jabber:x:oob', xmpp.Oob.XMLNS_X);
		final m = new Message('romeo@example.net').setOob('https://example.com/a.jpg');
		equals('https://example.com/a.jpg', m.getOob().firstElement.text);
	}

	function test_chat_state() {
		final m = new Message('romeo@example.net', 'hi');
		m.setChatState(composing);
		m.setChatState(paused);
		m.properties.push(XML.create('other'));
		equals(composing, m.getChatState());
		m.removeChatState();
		isNull(m.getChatState());
		equals(1, m.properties.length);
	}

	function test_adhoc_execute() {
		xmpp.AdHocCommand.execute(stream, 'responder@example.com', 'list', r -> {});
		final command = lastSent().firstElement;
		equals('command', command.name);
		equals('list', command.get('node'));
		equals('execute', command.get('action'));
	}

	function test_bob() {
		var response:Response<XML> = null;
		final iq = xmpp.Bob.requestBob(stream, 'ladymacbeth@shakespeare.lit/castle', 'sha1+8f35fef110ffc5df08d579a50083ff9308fb6242@bob.xmpp.org', r -> response = r);
		equals('data', lastSent().firstElement.name);
		stream.recv('<iq type="result" id="${iq.id}" from="ladymacbeth@shakespeare.lit/castle"><data xmlns="urn:xmpp:bob" cid="x" type="image/png">AAAA</data></iq>');
		isTrue(response.ok());
		equals('AAAA', response.payload.text);
	}

	function test_uri() {
		var uri = URI.parse('xmpp:romeo@montague.net');
		equals('romeo@montague.net', uri.jid);
		isNull(uri.action);
		isNull(uri.account);

		uri = URI.parse('xmpp:romeo@montague.net?message;subject=Test%20Message;body=Here%27s%20a%20test%20message');
		equals('message', uri.action);
		equals('Test Message', uri.params.get('subject'));
		equals("Here's a test message", uri.params.get('body'));

		uri = URI.parse('xmpp://guest@example.com/support@example.com?message');
		equals('guest@example.com', uri.account);
		equals('support@example.com', uri.jid);
		equals('message', uri.action);

		uri = URI.parse('xmpp:example-node@example.com?message;body=hi');
		equals('xmpp:example-node@example.com?message;body=hi', uri.toString());
		equals('xmpp:romeo@montague.net', URI.parse('xmpp:romeo@montague.net').toString());
		equals('xmpp://guest@example.com/support@example.com?message', URI.parse('xmpp://guest@example.com/support@example.com?message').toString());

		isTrue(URI.parse('xmpp:a@b?message;body=x') == URI.parse('xmpp:a@b?message;body=x'));
		isFalse(URI.parse('xmpp:a@b?message;body=x') == URI.parse('xmpp:a@b?message'));
		isNull(URI.parse('mailto:a@b'));
	}
}
