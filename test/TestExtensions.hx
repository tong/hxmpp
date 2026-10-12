import utest.Assert.*;
import xmpp.IQ;
import xmpp.ChatState;
import xmpp.LastMessageCorrection;
import xmpp.Message;
import xmpp.Response;
import xmpp.URI;
import xmpp.XML;

using xmpp.Attention;
using xmpp.ChatState;
using xmpp.DelayedDelivery;
using xmpp.HttpFileUpload;
using xmpp.LastMessageCorrection;
using xmpp.Oob;

class TestExtensions extends utest.Test {
	function test_last_message_correction() {
		final m = new Message('romeo@example.net', 'fixed').correct('msg42');
		final replace = m.toXML().elements.named('replace')[0];
		equals(LastMessageCorrection.XMLNS, replace.get('xmlns'));
		equals('msg42', replace.get('id'));
		notNull(m.id);
		notEquals('msg42', m.id);

		final m:Message = m.toString();
		equals('msg42', m.correction());
		isNull(new Message('romeo@example.net', 'hi').correction());

		// correcting again replaces the mark, the own id is kept
		final c = new Message('romeo@example.net', 'fixed');
		c.id = 'own';
		c.correct('a').correct('b');
		equals(1, c.toXML().elements.named('replace').length);
		equals('b', c.correction());
		equals('own', c.id);
		isNull(new Message('romeo@example.net', 'x').correct(null).correction());
	}

	function test_last_message_correction_valid() {
		// https://xmpp.org/extensions/xep-0308.html#business
		final original = Message.fromString('<message from="romeo@montague.net/orchard" type="chat" id="bad1"><body>airlock</body></message>');
		function correction(from:String, id = 'bad1', type = 'chat'):Message
			return Message.fromString('<message from="$from" type="$type" id="good1"><body>window</body><replace id="$id" xmlns="urn:xmpp:message-correct:0"/></message>');
		isTrue(LastMessageCorrection.isValidCorrection(original, correction('romeo@montague.net/orchard')));
		// other resource of the same user, case-insensitive
		isTrue(LastMessageCorrection.isValidCorrection(original, correction('Romeo@Montague.net/garden')));
		isFalse(LastMessageCorrection.isValidCorrection(original, correction('tybalt@capulet.net/street')));
		isFalse(LastMessageCorrection.isValidCorrection(original, correction('romeo@montague.net/orchard', 'other')));
		isFalse(LastMessageCorrection.isValidCorrection(original, new Message('romeo@example.net', 'hi')));

		// groupchat: the full jid (nick) must match
		final original = Message.fromString('<message from="room@muc.example.net/romeo" type="groupchat" id="bad1"><body>airlock</body></message>');
		isTrue(LastMessageCorrection.isValidCorrection(original, correction('room@muc.example.net/romeo', 'bad1', 'groupchat')));
		isFalse(LastMessageCorrection.isValidCorrection(original, correction('room@muc.example.net/tybalt', 'bad1', 'groupchat')));
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

		stream.recv('<iq from="Juliet@Capulet.com" type="set" id="push2"><unblock xmlns="urn:xmpp:blocking"/></iq>');
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
		#if !hl // hashlink dates have second resolution
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

	function test_http_upload_request() {
		xmpp.HttpFileUpload.requestHttpUploadSlot(stream, 'upload.montague.tld', 'très cool.jpg', 23456, 'image/jpeg', r -> {});
		var req = lastSent().firstElement;
		equals('upload.montague.tld', lastSent().get('to'));
		equals('get', lastSent().get('type'));
		equals('request', req.name);
		equals('très cool.jpg', req.get('filename'));
		equals('23456', req.get('size'));
		equals('image/jpeg', req.get('content-type'));
		equals(0, req.elements.length);

		// sizes above 2 GiB
		xmpp.HttpFileUpload.requestHttpUploadSlot(stream, 'upload.montague.tld', 'big.iso', 5000000000.0, r -> {});
		equals('5000000000', lastSent().firstElement.get('size'));

		xmpp.HttpFileUpload.requestHttpUploadSlot(stream, 'upload.montague.tld', 'avatar.png', 1000, Profile, r -> {});
		req = lastSent().firstElement;
		equals('profile', req.firstElement.name);
		equals(xmpp.HttpFileUpload.XMLNS_PURPOSE, req.firstElement.get('xmlns'));

		xmpp.HttpFileUpload.requestHttpUploadSlot(stream, 'upload.montague.tld', 'story.jpg', 1000, 'image/jpeg', Ephemeral(Date.fromTime(1781049600000.0)), r -> {});
		req = lastSent().firstElement;
		equals('ephemeral', req.firstElement.name);
		equals('2026-06-10T00:00:00Z', req.firstElement.get('expire-before'));
	}

	function test_http_upload_slot_parse() {
		// https://xmpp.org/extensions/xep-0363.html#request
		final slot = xmpp.HttpFileUpload.parseSlot(XML.fromString('<slot xmlns="urn:xmpp:http:upload:0">
			<put url="https://upload.montague.tld/4a771ac1-f0b2-4a4a-9700-f2a26fa2bb67/tr%C3%A8s%20cool.jpg">
				<header name="Authorization">Basic Base64String==</header>
				<header name="Cookie">foo=bar; user=romeo</header>
				<header name="eXpires">Tue, 1 Jan 2030 00:00:00 GMT</header>
				<header name="X-Evil">injected</header>
				<header name="Cookie">second=1</header>
			</put>
			<get url="https://download.montague.tld/4a771ac1-f0b2-4a4a-9700-f2a26fa2bb67/tr%C3%A8s%20cool.jpg"/>
		</slot>'));
		equals('https://upload.montague.tld/4a771ac1-f0b2-4a4a-9700-f2a26fa2bb67/tr%C3%A8s%20cool.jpg', slot.put);
		equals('https://download.montague.tld/4a771ac1-f0b2-4a4a-9700-f2a26fa2bb67/tr%C3%A8s%20cool.jpg', slot.get);
		equals('Authorization,Cookie,eXpires,Cookie', [for (h in slot.headers) h.name].join(','));
		equals('second=1', slot.headers[3].value);

		// newlines are removed
		final slot = xmpp.HttpFileUpload.parseSlot(XML.fromString('<slot xmlns="urn:xmpp:http:upload:0"><put url="https://u"><header name="Cookie">a=1\r\nX-Evil: 1</header></put><get url="https://g"/></slot>'));
		equals('a=1X-Evil: 1', slot.headers[0].value);

		isNull(xmpp.HttpFileUpload.parseSlot(XML.fromString('<slot xmlns="urn:xmpp:http:upload:0"><put url="https://u"/></slot>')));
	}

	function test_http_upload_errors() {
		// https://xmpp.org/extensions/xep-0363.html#errors
		final iq:IQ = '<iq type="error" id="step_03"><error type="modify"><not-acceptable xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/><text xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">File too large. The maximum file size is 20000 bytes</text><file-too-large xmlns="urn:xmpp:http:upload:0"><max-file-size>20000</max-file-size></file-too-large></error></iq>';
		equals(20000.0, xmpp.HttpFileUpload.getMaxFileSize(iq.error));
		isNull(xmpp.HttpFileUpload.getRetry(iq.error));

		final iq:IQ = '<iq type="error" id="step_03"><error type="wait"><resource-constraint xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/><text xmlns="urn:ietf:params:xml:ns:xmpp-stanzas">Quota reached. You can only upload 5 files in 5 minutes</text><retry xmlns="urn:xmpp:http:upload:0" stamp="2017-12-03T23:42:05Z"/></error></iq>';
		equals(1512344525000.0, xmpp.HttpFileUpload.getRetry(iq.error).getTime());
		isNull(xmpp.HttpFileUpload.getMaxFileSize(iq.error));

		isNull(xmpp.HttpFileUpload.getMaxFileSize(null));
		isNull(xmpp.HttpFileUpload.getRetry(new xmpp.Stanza.Error(cancel, not_allowed)));
	}

	function test_last_activity() {
		var response:Response<XML> = null;
		var iq = xmpp.LastActivity.getLastActivity(stream, r -> response = r);
		equals('example.com', lastSent().get('to'));
		equals(xmpp.LastActivity.XMLNS, lastSent().firstElement.get('xmlns'));

		// https://xmpp.org/extensions/xep-0012.html#offline
		iq = xmpp.LastActivity.getLastActivity(stream, 'juliet@capulet.com', r -> response = r);
		stream.recv('<iq type="result" id="${iq.id}" from="juliet@capulet.com"><query xmlns="jabber:iq:last" seconds="903">Heading Home</query></iq>');
		final last = xmpp.LastActivity.parse(response.payload);
		equals(903, last.seconds);
		equals('Heading Home', last.status);

		final last = xmpp.LastActivity.parse(XML.fromString('<query xmlns="jabber:iq:last" seconds="123"/>'));
		equals(123, last.seconds);
		isNull(last.status);
		isNull(xmpp.LastActivity.parse(XML.fromString('<query xmlns="jabber:iq:last"/>')));
		isNull(xmpp.LastActivity.parse(XML.fromString('<query xmlns="jabber:iq:last" seconds="x"/>')));
	}

	function test_last_activity_requests() {
		xmpp.LastActivity.handleRequests(stream, () -> 42);
		stream.recv('<iq type="get" id="l1" from="romeo@montague.net/orchard"><query xmlns="jabber:iq:last"/></iq>');
		equals('result', lastSent().get('type'));
		equals('l1', lastSent().get('id'));
		equals(42, xmpp.LastActivity.parse(lastSent().firstElement).seconds);
	}

	function test_oob() {
		equals('jabber:iq:oob', xmpp.Oob.XMLNS);
		equals('jabber:x:oob', xmpp.Oob.XMLNS_X);

		// https://xmpp.org/extensions/xep-0066.html#x-oob
		final m = new Message('romeo@example.net').setOob('https://example.com/a.jpg', 'A picture');
		final x = m.toXML().elements.named('x')[0];
		equals('https://example.com/a.jpg', x.elements.named('url')[0].text);
		equals('A picture', x.elements.named('desc')[0].text);
		equals(0, x.elements.named('description').length);
		final data = Message.fromString(m.toString()).getOob();
		equals('https://example.com/a.jpg', data.url);
		equals('A picture', data.desc);

		final p = xmpp.Presence.fromString('<presence><x xmlns="jabber:x:oob"><url>http://www.jabber.org/images/psa-license.jpg</url></x></presence>');
		final data = p.getOob();
		equals('http://www.jabber.org/images/psa-license.jpg', data.url);
		isNull(data.desc);

		isNull(new Message('romeo@example.net', 'hi').getOob());
		isNull(Message.fromString('<message><other xmlns="jabber:x:oob"><url>x</url></other></message>').getOob());
	}

	function test_oob_request() {
		// https://xmpp.org/extensions/xep-0066.html#iq-oob
		xmpp.Oob.oob(stream, 'MaineBoy@jabber.org/home', 'http://www.jabber.org/images/psa-license.jpg', 'A license to Jabber!', r -> {});
		final iq = lastSent();
		equals('set', iq.get('type'));
		equals('MaineBoy@jabber.org/home', iq.get('to'));
		equals('http://www.jabber.org/images/psa-license.jpg', iq.firstElement.elements.named('url')[0].text);
		equals('A license to Jabber!', iq.firstElement.elements.named('desc')[0].text);
	}

	function test_oob_handle_requests() {
		final requests = new Array<{url:String, desc:Null<String>, respond:xmpp.Oob.OobResult->Void}>();
		xmpp.Oob.handleRequests(stream, (url, desc, from, respond) -> requests.push({url: url, desc: desc, respond: respond}));
		function request(id:String)
			stream.recv('<iq type="set" id="$id" from="stpeter@jabber.org/work"><query xmlns="jabber:iq:oob"><url>http://www.jabber.org/images/psa-license.jpg</url><desc>A license to Jabber!</desc></query></iq>');

		final count = sent.length;
		request('o1');
		equals(1, requests.length);
		equals('A license to Jabber!', requests[0].desc);
		// no response before the file was retrieved
		equals(count, sent.length);
		requests[0].respond(Fetched);
		equals('result', lastSent().get('type'));
		equals('o1', lastSent().get('id'));

		request('o2');
		requests[1].respond(Failed);
		equals('error', lastSent().get('type'));
		equals('item-not-found', lastSent().elements.named('error')[0].firstElement.name);

		request('o3');
		requests[2].respond(Rejected);
		equals('not-acceptable', lastSent().elements.named('error')[0].firstElement.name);

		stream.recv('<iq type="set" id="o4" from="stpeter@jabber.org/work"><query xmlns="jabber:iq:oob"/></iq>');
		equals('bad-request', lastSent().elements.named('error')[0].firstElement.name);
	}

	function test_chat_state() {
		final m = new Message('romeo@example.net', 'hi');
		m.setChatState(composing);
		m.setChatState(paused);
		m.properties.push(XML.create('other'));
		equals(paused, m.getChatState());
		equals(1, m.toXML().elements.filter(e -> e.is(ChatState.XMLNS)).length);
		m.removeChatState();
		isNull(m.getChatState());
		equals(1, m.properties.length);

		// unknown elements in the namespace are no state
		isNull(Message.fromString('<message><foo xmlns="http://jabber.org/protocol/chatstates"/></message>').getChatState());
		equals(gone, Message.fromString('<message><gone xmlns="http://jabber.org/protocol/chatstates"/></message>').getChatState());

		final n = ChatState.createChatStateMessage('romeo@example.net', composing);
		final xml = n.toXML();
		equals('romeo@example.net', xml.get('to'));
		equals('chat', xml.get('type'));
		equals(1, xml.elements.length);
		equals('composing', xml.firstElement.name);
		equals(ChatState.XMLNS, xml.firstElement.get('xmlns'));
		equals('groupchat', ChatState.createChatStateMessage('room@muc.example.net', active, groupchat).toXML().get('type'));
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
