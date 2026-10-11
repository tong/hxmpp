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
}
