import utest.Assert.*;
import xmpp.IQ;
import xmpp.Message;
import xmpp.Response;
import xmpp.URI;
import xmpp.XML;

using xmpp.Attention;
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
		final iq = XML.fromString(sent[0]);
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
		return XML.fromString(sent[sent.length - 1]);

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

	function test_attention() {
		final m = new Message('romeo@example.net/orchard').captureAttention();
		equals(headline, m.type);
		m.captureAttention();
		final xml = m.toXML();
		equals(1, xml.elements.named('attention').length);
		equals(xmpp.Attention.XMLNS, xml.elements.named('attention')[0].get('xmlns'));
		isTrue(Message.fromString(xml.toString()).wantsAttention());

		isFalse(new Message('romeo@example.net', 'hi').wantsAttention());
		// other elements in the namespace are no request
		isFalse(Message.fromString('<message><other xmlns="urn:xmpp:attention:0"/></message>').wantsAttention());
		// delayed requests are ignored
		isFalse(Message.fromString('<message type="headline"><attention xmlns="urn:xmpp:attention:0"/><delay xmlns="urn:xmpp:delay" stamp="2026-10-12T10:00:00Z"/></message>')
			.wantsAttention());
	}

	function test_block() {
		xmpp.Block.block(stream, ['romeo@montague.net', 'iago@shakespeare.lit'], r -> {});
		var iq = lastSent();
		equals('set', iq.get('type'));
		isNull(iq.get('to'));
		equals('block', iq.firstElement.name);
		equals('romeo@montague.net,iago@shakespeare.lit', xmpp.Block.getItems(iq.firstElement).join(','));

		xmpp.Block.unblock(stream, ['romeo@montague.net'], r -> {});
		equals('romeo@montague.net', xmpp.Block.getItems(lastSent().firstElement).join(','));
		xmpp.Block.unblock(stream, r -> {});
		equals('unblock', lastSent().firstElement.name);
		equals(0, lastSent().firstElement.elements.length);

		var items:Array<String> = null;
		final iq = xmpp.Block.getBlocklist(stream, r -> items = xmpp.Block.getItems(r.payload));
		stream.recv('<iq type="result" id="${iq.id}"><blocklist xmlns="urn:xmpp:blocking"><item jid="romeo@montague.net"/><item jid="iago@shakespeare.lit"/></blocklist></iq>');
		equals(2, items.length);
	}

	function test_block_pushes() {
		@:privateAccess stream.jid = 'juliet@capulet.com/chamber';
		final pushes = new Array<String>();
		xmpp.Block.handlePushes(stream, (blocked, jids) -> pushes.push('$blocked:${jids.join(",")}'));

		stream.recv('<iq to="juliet@capulet.com/chamber" type="set" id="push1"><block xmlns="urn:xmpp:blocking"><item jid="romeo@montague.net"/></block></iq>');
		equals('true:romeo@montague.net', pushes.join(' '));
		equals('result', lastSent().get('type'));
		equals('push1', lastSent().get('id'));

		stream.recv('<iq from="juliet@capulet.com" type="set" id="push2"><unblock xmlns="urn:xmpp:blocking"/></iq>');
		equals('true:romeo@montague.net false:', pushes.join(' '));
		equals('result', lastSent().get('type'));

		// pushes from others are rejected
		stream.recv('<iq from="romeo@montague.net/orchard" type="set" id="push3"><unblock xmlns="urn:xmpp:blocking"><item jid="romeo@montague.net"/></unblock></iq>');
		equals(2, pushes.length);
		equals('error', lastSent().get('type'));
		equals('push3', lastSent().get('id'));
	}

	function test_block_error() {
		final m = Message.fromString('<message type="error" from="romeo@montague.net"><error type="cancel"><not-acceptable xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/><blocked xmlns="urn:xmpp:blocking:errors"/></error></message>');
		isTrue(xmpp.Block.isBlockedError(m.error));
		isFalse(xmpp.Block.isBlockedError(new xmpp.Stanza.Error(cancel, not_acceptable)));
		isFalse(xmpp.Block.isBlockedError(null));
	}

	function test_carbons() {
		xmpp.Carbons.enableMessageCarbons(stream, r -> {});
		equals('set', lastSent().get('type'));
		isNull(lastSent().get('to'));
		equals('enable', lastSent().firstElement.name);
		equals(xmpp.Carbons.XMLNS, lastSent().firstElement.get('xmlns'));

		@:privateAccess stream.jid = 'juliet@capulet.lit/balcony';
		function carbon(from:String, kind:String):Message
			return Message.fromString('<message from="$from" to="juliet@capulet.lit/balcony" type="chat">'
				+ '<$kind xmlns="urn:xmpp:carbons:2"><forwarded xmlns="urn:xmpp:forward:0">'
				+ '<message from="romeo@montague.lit/home" to="juliet@capulet.lit/chamber" type="chat"><body>Wherefore art thou?</body></message>'
				+ '</forwarded></$kind></message>');

		final c = xmpp.Carbons.getCarbon(stream, carbon('juliet@capulet.lit', 'received'));
		isFalse(c.sent);
		equals('romeo@montague.lit/home', c.message.from);
		equals('Wherefore art thou?', c.message.body);
		isTrue(xmpp.Carbons.getCarbon(stream, carbon('Juliet@Capulet.lit', 'sent')).sent);

		// forged or invalid copies are ignored
		isNull(xmpp.Carbons.getCarbon(stream, carbon('romeo@montague.lit', 'sent')));
		isNull(xmpp.Carbons.getCarbon(stream, carbon('romeo@montague.lit/home', 'received')));
		isNull(xmpp.Carbons.getCarbon(stream, carbon('juliet@capulet.lit/chamber', 'sent')));
		isNull(xmpp.Carbons.getCarbon(stream, Message.fromString('<message><sent xmlns="urn:xmpp:carbons:2"><forwarded xmlns="urn:xmpp:forward:0"><message><body>x</body></message></forwarded></sent></message>')));
		isNull(xmpp.Carbons.getCarbon(stream, Message.fromString('<message from="juliet@capulet.lit"><sent xmlns="urn:xmpp:carbons:2"/></message>')));
		isNull(xmpp.Carbons.getCarbon(stream, new Message('romeo@montague.lit', 'hi')));

		// unknown own jid (before resource binding)
		@:privateAccess stream.jid = null;
		isNull(xmpp.Carbons.getCarbon(stream, carbon('juliet@capulet.lit', 'received')));

		final m = xmpp.Carbons.makePrivate(xmpp.Carbons.makePrivate(new Message('romeo@montague.lit', 'secret')));
		final xml = m.toXML();
		equals(1, xml.elements.named('private').length);
		equals(xmpp.Carbons.XMLNS, xml.elements.named('private')[0].get('xmlns'));
		equals(1, xml.elements.named('no-copy').length);
		equals('urn:xmpp:hints', xml.elements.named('no-copy')[0].get('xmlns'));
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
		final bytes = haxe.io.Bytes.ofString('hello bob');
		final cid = xmpp.Bob.cid(bytes);
		equals('sha1+${haxe.crypto.Sha1.make(bytes).toHex()}@bob.xmpp.org', cid);

		final xml = xmpp.Bob.create(bytes, 'text/plain', 86400);
		equals(xmpp.Bob.XMLNS, xml.get('xmlns'));
		equals(cid, xml.get('cid'));
		equals('text/plain', xml.get('type'));
		equals('86400', xml.get('max-age'));
		final text:String = xml.text;
		isFalse(text.indexOf('\n') != -1);

		final data = xmpp.Bob.parse(XML.fromString(xml.toString()));
		equals(cid, data.cid);
		equals('text/plain', data.type);
		equals(86400, data.maxAge);
		equals('hello bob', data.bytes.toString());
		isTrue(data.verified);

		// data with line breaks
		final data = xmpp.Bob.parse(XML.fromString('<data xmlns="urn:xmpp:bob" cid="$cid" type="text/plain">aGVsbG8g\n  Ym9i</data>'));
		equals('hello bob', data.bytes.toString());

		// sha-256 cid
		final cid256 = 'sha-256+${haxe.crypto.Sha256.make(bytes).toHex()}@bob.xmpp.org';
		isTrue(xmpp.Bob.parse(XML.fromString('<data xmlns="urn:xmpp:bob" cid="$cid256" type="text/plain">aGVsbG8gYm9i</data>')).verified);

		// unsupported algorithm: not verified, but accepted
		final data = xmpp.Bob.parse(XML.fromString('<data xmlns="urn:xmpp:bob" cid="md5+00ff@bob.xmpp.org" type="text/plain">aGVsbG8gYm9i</data>'));
		isFalse(data.verified);
		equals('hello bob', data.bytes.toString());

		// the example of XEP-0231: the data does not match the hash of the cid
		isNull(xmpp.Bob.parse(XML.fromString('<data xmlns="urn:xmpp:bob" cid="sha1+8f35fef110ffc5df08d579a50083ff9308fb6242@bob.xmpp.org" max-age="86400" type="image/png">iVBORw0KGgoAAAANSUhEUgAAAAoAAAAKCAYAAACNMs+9AAAABGdBTUEAALGP</data>')));

		// empty data element (no content)
		final data = xmpp.Bob.parse(XML.fromString('<data xmlns="urn:xmpp:bob" cid="$cid"/>'));
		isNull(data.bytes);
		isFalse(data.verified);
	}

	function test_bob_message() {
		final bytes = haxe.io.Bytes.ofString('tiny');
		final m = new Message('romeo@example.net', 'look');
		m.properties.push(xmpp.Bob.create(bytes, 'text/plain', 0));
		m.properties.push(XML.fromString('<data xmlns="urn:xmpp:bob" cid="sha1+0000@bob.xmpp.org" type="text/plain">dGlueQ==</data>'));
		final data = xmpp.Bob.getData(Message.fromString(m.toString()));
		equals(1, data.length);
		equals('tiny', data[0].bytes.toString());
		equals(0, data[0].maxAge);
	}

	function test_bob_request() {
		var response:Response<XML> = null;
		final iq = xmpp.Bob.requestBob(stream, 'ladymacbeth@shakespeare.lit/castle', 'sha1+8f35fef110ffc5df08d579a50083ff9308fb6242@bob.xmpp.org', r -> response = r);
		equals('data', lastSent().firstElement.name);
		equals('get', lastSent().get('type'));
		stream.recv('<iq type="result" id="${iq.id}" from="ladymacbeth@shakespeare.lit/castle"><data xmlns="urn:xmpp:bob" cid="x" type="image/png">AAAA</data></iq>');
		isTrue(response.ok());
		equals('AAAA', response.payload.text);
	}

	function test_bob_handle_requests() {
		final bytes = haxe.io.Bytes.ofString('hello bob');
		final cid = xmpp.Bob.cid(bytes);
		xmpp.Bob.handleRequests(stream, c -> c == cid ? xmpp.Bob.create(bytes, 'text/plain') : null);

		stream.recv('<iq type="get" id="r1" from="romeo@example.net/orchard"><data xmlns="urn:xmpp:bob" cid="$cid"/></iq>');
		var iq = lastSent();
		equals('result', iq.get('type'));
		equals('r1', iq.get('id'));
		equals('hello bob', xmpp.Bob.parse(iq.firstElement).bytes.toString());

		stream.recv('<iq type="get" id="r2" from="romeo@example.net/orchard"><data xmlns="urn:xmpp:bob" cid="sha1+00@bob.xmpp.org"/></iq>');
		iq = lastSent();
		equals('error', iq.get('type'));
		equals('item-not-found', iq.elements.named('error')[0].firstElement.name);
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
