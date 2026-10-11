import utest.Assert.*;
import xmpp.Response;
import xmpp.Stanza;
import xmpp.XML;

class TestStream extends utest.Test {
	function test_stream_client_namespace() {
		var stream = new xmpp.client.Stream('example.com');
		equals(xmpp.client.Stream.XMLNS, stream.xmlns);
		equals('example.com', stream.domain);
		equals('1.0', stream.version);
		isNull(stream.id);
		isNull(stream.lang);
		isNull(stream.input);
		isNull(stream.output);
		isFalse(stream.ready);
	}

	function test_stream_component_namespace() {
		var stream = new xmpp.component.Stream("mycomponent", "example.com");
		equals(xmpp.component.Stream.XMLNS, stream.xmlns);
		equals("mycomponent", stream.name);
		equals("example.com", stream.domain);
		equals("1.0", stream.version);
		isNull(stream.id);
		isNull(stream.lang);
		isNull(stream.input);
		isNull(stream.output);
		isFalse(stream.ready);
	}

	function test_stream_header_namespace() {
		var out:String = null;
		function header():XML
			return XML.parse(out + '</stream:stream>').firstElement;

		var stream = new xmpp.client.Stream('example.com');
		stream.output = str -> out = str;
		stream.start(features -> {});
		equals(xmpp.client.Stream.XMLNS, header().get('xmlns'));
		equals('example.com', header().get('to'));

		var stream = new xmpp.client.Stream('example.com', 'jabber:server');
		stream.output = str -> out = str;
		stream.start(features -> {});
		equals('jabber:server', header().get('xmlns'));

		var stream = new xmpp.component.Stream('mycomponent', 'example.com');
		stream.output = str -> out = str;
		stream.start('secret', (?error) -> {});
		equals(xmpp.component.Stream.XMLNS, header().get('xmlns'));
		equals('mycomponent.example.com', header().get('to'));

		var stream = new xmpp.component.Stream('mycomponent', 'example.com', 'jabber:component:connect');
		stream.output = str -> out = str;
		stream.start('secret', (?error) -> {});
		equals('jabber:component:connect', header().get('xmlns'));
	}

	@:access(xmpp.Stream)
	function test_read_header() {
		var header = xmpp.Stream.readHeader("<?xml version='1.0'?><stream:stream xml:lang='en' xmlns:stream='http://etherx.jabber.org/streams' version='1.0' from='example.com' to='user@example.com' xmlns='jabber:client' id='abc123'>");
		equals('abc123', header.id);
		equals('example.com', header.from);
		equals('user@example.com', header.to);
		equals('1.0', header.version);
		equals('en', header.lang);
	}

	function test_stream_stanza_namespace() {
		var stream = new xmpp.client.Stream('example.com');
		var messages = 0;
		var nonzas = 0;
		stream.onMessage = m -> messages++;
		stream.onNonza = xml -> {
			nonzas++;
			return true;
		}
		stream.output = str -> {};
		stream.start(features -> {});
		stream.recv("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='abc' from='example.com' version='1.0'><stream:features></stream:features>");
		isTrue(stream.ready);
		stream.recv("<message from='a@example.com'><body>hi</body></message>");
		equals(1, messages);
		stream.recv("<message xmlns='jabber:client' from='a@example.com'><body>hi</body></message>");
		equals(2, messages);
		stream.recv("<message xmlns='jabber:server' from='a@example.com'><body>hi</body></message>");
		equals(2, messages);
		stream.recv("<r xmlns='urn:xmpp:sm:3'/>");
		equals(1, nonzas);
	}

	function createReadyStream():xmpp.client.Stream {
		final stream = new xmpp.client.Stream('example.com');
		stream.output = str -> {};
		stream.start(features -> {});
		stream.recv("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='abc' from='example.com' version='1.0'><stream:features></stream:features>");
		return stream;
	}

	function test_response_sender() {
		final stream = createReadyStream();
		var responses = 0;
		final iq = stream.get(xmpp.IQ.Payload.create('urn:xmpp:ping', 'ping'), 'romeo@example.com/balcony', (r:Response<XML>) -> responses++);
		stream.recv('<iq type="result" id="${iq.id}" from="mallory@example.com/x"/>');
		equals(0, responses);
		stream.recv('<iq type="result" id="${iq.id}" from="romeo@example.com/orchard"/>');
		equals(0, responses);
		stream.recv('<iq type="result" id="${iq.id}" from="romeo@example.com/balcony"/>');
		equals(1, responses);
		// only handled once
		stream.recv('<iq type="result" id="${iq.id}" from="romeo@example.com/balcony"/>');
		equals(1, responses);

		// domain is case-insensitive
		final iq = stream.get(xmpp.IQ.Payload.create('urn:xmpp:ping', 'ping'), 'Example.COM', (r:Response<XML>) -> responses++);
		stream.recv('<iq type="error" id="${iq.id}" from="example.com"><error type="cancel"><service-unavailable xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></iq>');
		equals(2, responses);
	}

	function test_response_type() {
		final stream = createReadyStream();
		var responses = 0;
		var requests = 0;
		stream.onIQ = (iq, res) -> requests++;
		var messages = 0;
		stream.onMessage = m -> messages++;
		final iq = stream.get(xmpp.IQ.Payload.create('urn:xmpp:ping', 'ping'), 'romeo@example.com/balcony', (r:Response<XML>) -> responses++);
		// requests and messages reusing a pending id are not responses
		stream.recv('<iq type="get" id="${iq.id}" from="romeo@example.com/balcony"><query xmlns="jabber:iq:version"/></iq>');
		stream.recv('<message id="${iq.id}" from="romeo@example.com/balcony"><body>hi</body></message>');
		equals(0, responses);
		equals(1, requests);
		equals(1, messages);
		stream.recv('<iq type="result" id="${iq.id}" from="romeo@example.com/balcony"/>');
		equals(1, responses);
	}

	@:access(xmpp.Stream)
	function test_response_own_account() {
		final stream = createReadyStream();
		var responses = 0;
		function request()
			return stream.get('jabber:iq:roster', (r:Response<XML>) -> responses++);

		// before resource binding
		final iq = request();
		stream.recv('<iq type="result" id="${iq.id}" from="mallory@example.com"/>');
		equals(0, responses);
		stream.recv('<iq type="result" id="${iq.id}"/>');
		equals(1, responses);
		final iq = request();
		stream.recv('<iq type="result" id="${iq.id}" from="example.com"/>');
		equals(2, responses);

		stream.jid = 'juliet@example.com/balcony';
		final iq = request();
		stream.recv('<iq type="result" id="${iq.id}" from="example.com"/>');
		stream.recv('<iq type="result" id="${iq.id}" from="romeo@example.com"/>');
		equals(2, responses);
		stream.recv('<iq type="result" id="${iq.id}" from="juliet@example.com"/>');
		equals(3, responses);
		final iq = request();
		stream.recv('<iq type="result" id="${iq.id}" from="juliet@example.com/balcony"/>');
		equals(4, responses);
		final iq = request();
		stream.recv('<iq type="result" id="${iq.id}"/>');
		equals(5, responses);
	}

	function test_response_presence() {
		final stream = createReadyStream();
		var responses = 0;
		var presences = 0;
		stream.onPresence = p -> presences++;
		final p = new xmpp.Presence();
		p.to = 'room@muc.example.com/juliet';
		stream.query(p, xml -> responses++);
		stream.recv('<presence id="${p.id}" from="other@muc.example.com/juliet"/>');
		equals(0, responses);
		equals(1, presences);
		// the room may assign another nick
		stream.recv('<presence id="${p.id}" from="room@muc.example.com/juliet2"/>');
		equals(1, responses);
		equals(1, presences);
	}
}
