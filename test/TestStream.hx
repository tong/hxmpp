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
			return XML.fromString(out + '</stream:stream>');

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

	function test_random_id() {
		final id = xmpp.Stream.makeRandomId();
		equals(16, id.length);
		isTrue(~/^[0-9a-f]+$/.match(id));
		equals(8, xmpp.Stream.makeRandomId(8).length);
		equals(7, xmpp.Stream.makeRandomId(7).length);
		final ids = [for (_ in 0...100) xmpp.Stream.makeRandomId()];
		for (i in 0...ids.length)
			for (j in i + 1...ids.length)
				if (ids[i] == ids[j])
					fail('duplicate id ${ids[i]}');
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

	static inline var SERVER_HEADER = "<?xml version='1.0'?><stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='abc' from='example.com' version='1.0'>";
	static inline var SERVER_FEATURES = "<stream:features><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/></stream:features>";

	function test_framing_split() {
		// Feed a whole session char by char
		final data = SERVER_HEADER + SERVER_FEATURES
			+ "<message from='a@example.com' id='x>y'><body>a &gt; b</body></message>"
			+ " \n "
			+ "<presence from='b@example.com/r'/>"
			+ "<message from='c@example.com'><x xmlns='urn:x'><x/></x><body><![CDATA[1 < 2]]></body></message>";
		final stream = new xmpp.client.Stream('example.com');
		final bodies = new Array<String>();
		final ids = new Array<String>();
		var presences = 0;
		var features:XML = null;
		stream.onMessage = m -> {
			bodies.push(m.body);
			ids.push(m.id);
		}
		stream.onPresence = p -> presences++;
		stream.output = str -> {};
		stream.start(f -> features = f);
		for (i in 0...data.length)
			stream.recv(data.charAt(i));
		equals('abc', stream.id);
		equals('stream:features', features.name);
		equals(2, bodies.length);
		equals('a > b', bodies[0]);
		equals('x>y', ids[0]);
		equals('1 < 2', bodies[1]);
		equals(1, presences);
	}

	function test_framing_chunk_ends_with_tag() {
		final stream = createReadyStream();
		final bodies = new Array<String>();
		stream.onMessage = m -> bodies.push(m.body);
		isFalse(stream.recv("<message from='a@example.com'><body>"));
		equals(0, bodies.length);
		isTrue(stream.recv("hi</body></message>"));
		equals(1, bodies.length);
		equals('hi', bodies[0]);
	}

	function test_framing_stream_end() {
		final stream = createReadyStream();
		final events = new Array<String>();
		stream.onMessage = m -> events.push(m.body);
		stream.onEnd = () -> events.push('end');
		stream.recv("<message><body>1</body></message><message><body>2</body></message></stream:stream>");
		equals('1,2,end', events.join(','));
		isFalse(stream.ready);
	}

	function test_framing_not_well_formed() {
		final stream = createReadyStream();
		final sent = new Array<String>();
		stream.output = str -> sent.push(str);
		stream.recv("<message><body>a</bdy></message>");
		isTrue(sent[0].indexOf('not-well-formed') != -1);
		equals('</stream:stream>', sent[1]);
	}

	function test_framing_max_buffer_size() {
		final stream = createReadyStream();
		final sent = new Array<String>();
		stream.output = str -> sent.push(str);
		stream.maxBufferSize = 100;
		stream.recv("<message><body>" + StringTools.lpad("", "x", 50));
		equals(0, sent.length);
		stream.recv(StringTools.lpad("", "x", 50));
		isTrue(sent[0].indexOf('policy-violation') != -1);
		equals('</stream:stream>', sent[1]);
		isFalse(stream.ready);

		// complete units larger than the limit are not affected
		final stream = createReadyStream();
		var bodies = 0;
		stream.onMessage = m -> bodies++;
		stream.maxBufferSize = 100;
		stream.recv("<message><body>" + StringTools.lpad("", "x", 200) + "</body></message>");
		equals(1, bodies);
	}

	function test_iq_requests() {
		final stream = createReadyStream();
		final sent = new Array<String>();
		stream.output = str -> sent.push(str);
		function last():XML
			return XML.fromString(sent[sent.length - 1]);
		function condition():String
			return last().elements.named('error')[0].firstElement.name;

		// unhandled requests: service-unavailable by default
		stream.recv('<iq type="get" id="q1" from="romeo@example.net/orchard"><query xmlns="jabber:iq:version"/></iq>');
		equals('error', last().get('type'));
		equals('q1', last().get('id'));
		equals('service-unavailable', condition());

		// handler answering null: service-unavailable
		stream.onIQ = (iq, res) -> res(null);
		stream.recv('<iq type="set" id="q2" from="romeo@example.net/orchard"><query xmlns="urn:x"/></iq>');
		equals('service-unavailable', condition());

		// handler answering a result
		stream.onIQ = (iq, res) -> res(Result(null));
		stream.recv('<iq type="get" id="q3" from="romeo@example.net/orchard"><query xmlns="urn:x"/></iq>');
		equals('result', last().get('type'));
		equals('q3', last().get('id'));

		// request without payload, missing and invalid type: bad-request
		stream.recv('<iq type="get" id="q4" from="romeo@example.net/orchard"/>');
		equals('q4', last().get('id'));
		equals('bad-request', condition());
		stream.recv('<iq id="q5" from="romeo@example.net/orchard"><query xmlns="urn:x"/></iq>');
		equals('q5', last().get('id'));
		equals('bad-request', condition());
		stream.recv('<iq type="bogus" id="q6" from="romeo@example.net/orchard"><query xmlns="urn:x"/></iq>');
		equals('q6', last().get('id'));
		equals('bad-request', condition());

		// request without id: no response
		final count = sent.length;
		stream.recv('<iq type="get" from="romeo@example.net/orchard"><query xmlns="urn:x"/></iq>');
		equals(count, sent.length);
	}

	function test_presence_invalid_type() {
		final stream = createReadyStream();
		final types = new Array<String>();
		stream.onPresence = p -> types.push(p.type ?? 'available');
		stream.recv('<presence from="romeo@example.net/orchard"/>');
		stream.recv('<presence from="romeo@example.net/orchard" type="bogus"/>');
		stream.recv('<presence from="romeo@example.net/orchard" type="unavailable"/>');
		equals('available,unavailable', types.join(','));
	}

	function test_error_response_without_error() {
		final stream = createReadyStream();
		var response:Response<XML> = null;
		final iq = stream.get('jabber:iq:version', r -> response = r);
		stream.recv('<iq type="error" id="${iq.id}" from="example.com"/>');
		isFalse(response.ok());
		equals(undefined_condition, response.error.condition);
	}

	function test_request_before_start() {
		final stream = new xmpp.client.Stream('example.com');
		final sent = new Array<String>();
		stream.output = str -> sent.push(str);
		stream.get('jabber:iq:version', r -> {});
		equals(1, sent.length);
	}

	static inline var COMPONENT_HEADER = "<stream:stream xmlns:stream='http://etherx.jabber.org/streams' xmlns='jabber:component:accept' from='plays.shakespeare.lit' id='3BF96D32'>";

	function startComponent(?data:Array<String>):{stream:xmpp.component.Stream, sent:Array<String>, results:Array<Null<xmpp.Stanza.Error>>, ends:Int} {
		final r = {stream: new xmpp.component.Stream('plays', 'shakespeare.lit'), sent: [], results: [], ends: 0};
		r.stream.output = str -> r.sent.push(str);
		r.stream.onEnd = () -> r.ends++;
		r.stream.start('secret', (?error) -> r.results.push(error));
		if (data != null)
			for (d in data)
				r.stream.recv(d);
		return r;
	}

	function test_component_host() {
		final stream = new xmpp.component.Stream('plays', 'shakespeare.lit');
		equals('plays.shakespeare.lit', stream.host);
		equals('shakespeare.lit', stream.domain);
		final stream = new xmpp.component.Stream('upload.example.org');
		equals('upload.example.org', stream.host);
		equals('upload.example.org', stream.name);
		equals('upload.example.org', stream.domain);
		stream.output = str -> {};
		equals(stream, stream.start('secret', (?e) -> {}));
		equals('upload.example.org', stream.jid);
	}

	function test_component_handshake() {
		// https://xmpp.org/extensions/xep-0114.html#protocol
		final c = startComponent([COMPONENT_HEADER]);
		equals(2, c.sent.length);
		final handshake = XML.fromString(c.sent[1]);
		equals('handshake', handshake.name);
		equals(haxe.crypto.Sha1.encode('3BF96D32secret'), handshake.text);
		equals('3BF96D32', c.stream.id);
		isFalse(c.stream.ready);
		equals(0, c.results.length);
		c.stream.recv('<handshake/>');
		isTrue(c.stream.ready);
		equals(1, c.results.length);
		isNull(c.results[0]);
	}

	function test_component_handshake_errors() {
		// invalid secret
		var c = startComponent([COMPONENT_HEADER, "<stream:error><not-authorized xmlns='urn:ietf:params:xml:ns:xmpp-streams'/></stream:error></stream:stream>"]);
		equals(1, c.results.length);
		equals(not_authorized, c.results[0].condition);
		isFalse(c.stream.ready);
		equals(1, c.ends);

		// error related to the stream header (header, error and stream end at once)
		c = startComponent([COMPONENT_HEADER + "<stream:error><host-unknown xmlns='urn:ietf:params:xml:ns:xmpp-streams'/><text xmlns='urn:ietf:params:xml:ns:xmpp-streams'>Unknown component</text><app xmlns='urn:example'/></stream:error></stream:stream>"]);
		equals(1, c.results.length);
		equals('host-unknown', c.results[0].condition);
		equals('Unknown component', c.results[0].text);

		// stream closed
		c = startComponent([COMPONENT_HEADER, '</stream:stream>']);
		equals(1, c.results.length);
		equals(undefined_condition, c.results[0].condition);
		equals(1, c.ends);

		// missing stream id
		c = startComponent(["<stream:stream xmlns:stream='http://etherx.jabber.org/streams' xmlns='jabber:component:accept'>", '<handshake/>']);
		equals(1, c.results.length);
		equals('invalid-id', c.results[0].condition);
		equals('</stream:stream>', c.sent[c.sent.length - 1]);
		equals(1, c.sent.filter(s -> s == '</stream:stream>').length);
		equals(0, c.sent.filter(s -> s.indexOf('handshake') != -1).length);

		// unexpected element
		c = startComponent([COMPONENT_HEADER, '<foo/>', '<handshake/>']);
		equals(1, c.results.length);
		equals(undefined_condition, c.results[0].condition);
		isFalse(c.stream.ready);
		equals('</stream:stream>', c.sent[c.sent.length - 1]);
	}

	function test_component_from() {
		final c = startComponent([COMPONENT_HEADER, '<handshake/>']);
		final sent = c.sent;
		function last():XML
			return XML.fromString(sent[sent.length - 1]);

		c.stream.get('jabber:iq:version', 'juliet@example.com', r -> {});
		equals('plays.shakespeare.lit', last().get('from'));
		equals('juliet@example.com', last().get('to'));
		c.stream.send(new xmpp.Message('juliet@example.com', 'hi'));
		equals('plays.shakespeare.lit', last().get('from'));
		final m = new xmpp.Message('juliet@example.com', 'hi');
		m.from = 'bot@plays.shakespeare.lit';
		c.stream.send(m);
		equals('bot@plays.shakespeare.lit', last().get('from'));
		// nonzas are not stamped
		c.stream.send(XML.create('foo'));
		isFalse(last().has('from'));

		// responses are sent from the address of the request
		c.stream.recv("<iq type='get' id='p1' from='juliet@example.com/balcony' to='bot@plays.shakespeare.lit'><ping xmlns='urn:xmpp:ping'/></iq>");
		equals('error', last().get('type'));
		equals('bot@plays.shakespeare.lit', last().get('from'));
		equals('juliet@example.com/balcony', last().get('to'));
		xmpp.Ping.handleRequests(c.stream);
		c.stream.recv("<iq type='get' id='p2' from='juliet@example.com/balcony' to='plays.shakespeare.lit'><ping xmlns='urn:xmpp:ping'/></iq>");
		equals('result', last().get('type'));
		equals('plays.shakespeare.lit', last().get('from'));

		// client streams do not set from
		final stream = new xmpp.client.Stream('example.com');
		final out = [];
		stream.output = str -> out.push(str);
		stream.start(f -> {});
		stream.recv("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='abc' from='example.com' version='1.0'><stream:features></stream:features>");
		stream.recv("<iq type='get' id='p3' from='example.com'><ping xmlns='urn:xmpp:ping'/></iq>");
		isFalse(XML.fromString(out[out.length - 1]).has('from'));
	}
}
