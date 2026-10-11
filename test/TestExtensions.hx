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

	function test_pubsub() {
		xmpp.PubSub.retractItem(stream, 'pubsub.example.com', 'news', 'item1', r -> {});
		var iq = lastSent();
		equals('set', iq.get('type'));
		equals('pubsub.example.com', iq.get('to'));
		final retract = iq.firstElement.firstElement;
		equals('retract', retract.name);
		equals('item1', retract.firstElement.get('id'));

		xmpp.PubSub.publish(stream, 'pubsub.example.com', 'news', XML.create('item'), r -> {});
		iq = lastSent();
		equals('set', iq.get('type'));
		equals('pubsub.example.com', iq.get('to'));
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
