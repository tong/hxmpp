import utest.Assert.*;
import xmpp.Response;
import xmpp.XML;
import xmpp.net.BOSH;

using xmpp.client.Authentication;

/**
	A request made by the session, answered by the test.
**/
private typedef HttpRequest = {
	body:XML,
	onResponse:String->Void,
	onError:String->Void
}

class TestBOSH extends utest.Test {
	static inline var URL = 'https://example.com/http-bind';
	static inline var SID = 'SomeSID';
	static inline var MECHANISMS = "<mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'><mechanism>PLAIN</mechanism></mechanisms>";
	static inline var BODY_NS = "xmlns='http://jabber.org/protocol/httpbind' xmlns:stream='http://etherx.jabber.org/streams'";

	var bosh:BOSH;
	var stream:xmpp.client.Stream;
	var http:Array<HttpRequest>;
	var errors:Array<String>;
	var ended:Int;
	var redirected:Null<String>;

	function setup() {
		http = [];
		errors = [];
		ended = 0;
		redirected = null;
		bosh = new BOSH(URL);
		bosh.request = (body, onResponse, onError) -> http.push({body: XML.fromString(body), onResponse: onResponse, onError: onError});
		bosh.onError = e -> errors.push(e);
		stream = new xmpp.client.Stream('example.com', null, 'en');
		stream.onEnd = () -> ended++;
		stream.onRedirect = uri -> redirected = uri;
		bosh.attach(stream);
	}

	/** Answers the oldest unanswered request **/
	function respond(body:String):HttpRequest {
		final r = http.shift();
		r.onResponse(body);
		return r;
	}

	function respondEmpty():HttpRequest
		return respond('<body $BODY_NS/>');

	function sessionResponse(attributes = '', content = '<stream:features>$MECHANISMS</stream:features>'):HttpRequest
		return respond('<body sid="$SID" wait="60" hold="1" requests="2" polling="5" inactivity="30" maxpause="120" ack="' + http[0].body.get('rid') +
			'" $attributes $BODY_NS xmlns:xmpp="urn:xmpp:xbosh" xmpp:version="1.0" xmpp:restartlogic="true">$content</body>');

	/** Creates the session, returns the features **/
	function connect(?attributes:String):XML {
		var features:XML = null;
		stream.start(f -> features = f);
		sessionResponse(attributes ?? '');
		return features;
	}

	/** Creates the session and authenticates (resource binding included) **/
	function login() {
		connect();
		stream.authenticate('juliet', 'balcony', 'secret', new sasl.PlainMechanism(), (?e) -> {});
		respond('<body $BODY_NS><success xmlns="urn:ietf:params:xml:ns:xmpp-sasl"/></body>');
		// restart
		respond('<body $BODY_NS><stream:features><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"/></stream:features></body>');
		// bind
		final iq = http[0].body.firstElement;
		respond('<body $BODY_NS><iq type="result" id="${iq.get('id')}" xmlns="jabber:client"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"><jid>juliet@example.com/balcony</jid></bind></iq></body>');
		// the empty request keeping the session alive
		equals(1, http.length);
		equals(0, http[0].body.elements.length);
	}

	function test_session_creation() {
		isNull(bosh.sid);
		notNull(stream.output);
		isTrue(bosh.stream == stream);

		var features:XML = null;
		stream.start(f -> features = f);
		equals(1, http.length);
		final body = http[0].body;
		equals('body', body.name);
		equals(BOSH.XMLNS, body.ns);
		equals('example.com', body.get('to'));
		equals('en', body.get('xml:lang'));
		equals(BOSH.VERSION, body.get('ver'));
		equals('60', body.get('wait'));
		equals('1', body.get('hold'));
		equals('1', body.get('ack'));
		equals('1.0', body.get('xmpp:version'));
		equals(BOSH.XMLNS_XBOSH, body.get('xmlns:xmpp'));
		isFalse(body.has('sid'));
		isFalse(body.has('route'));
		isFalse(body.has('from'));
		final rid = Std.parseInt(body.get('rid'));
		isTrue(rid > 0);
		equals(rid, bosh.rid);
		equals(1, bosh.pending);
		isNull(features);

		sessionResponse("from='example.com'");
		equals(SID, bosh.sid);
		equals(2, bosh.requests);
		equals(5, bosh.polling);
		equals(30, bosh.inactivity);
		equals(120, bosh.maxpause);
		equals(60, bosh.wait);
		equals(1, bosh.hold);
		notNull(features);
		equals('stream:features', features.name);
		isTrue(stream.ready);
		// the session is kept alive with an empty request
		equals(1, http.length);
		equals(rid + 1, Std.parseInt(http[0].body.get('rid')));
		equals(SID, http[0].body.get('sid'));
		equals(0, http[0].body.elements.length);
		isFalse(http[0].body.has('ack'));
		isFalse(http[0].body.has('to'));
		isFalse(http[0].body.has('wait'));
	}

	function test_session_creation_options() {
		bosh = new BOSH(URL, 2, 30);
		bosh.route = 'xmpp:example.com:5222';
		bosh.from = 'juliet@example.com';
		bosh.request = (body, onResponse, onError) -> http.push({body: XML.fromString(body), onResponse: onResponse, onError: onError});
		bosh.attach(stream);
		stream.start(f -> {});
		final body = http[0].body;
		equals('30', body.get('wait'));
		equals('2', body.get('hold'));
		equals('xmpp:example.com:5222', body.get('route'));
		equals('juliet@example.com', body.get('from'));
		// the connection manager lowers the values
		respond('<body sid="$SID" wait="20" hold="1" $BODY_NS><stream:features>$MECHANISMS</stream:features></body>');
		equals(20, bosh.wait);
		equals(1, bosh.hold);
		isNull(bosh.requests);
		isNull(bosh.polling);
		isNull(bosh.maxpause);
	}

	function test_features_in_later_response() {
		var features:XML = null;
		stream.start(f -> features = f);
		sessionResponse('', '');
		isNull(features);
		equals(SID, bosh.sid);
		equals(1, http.length);
		respond('<body $BODY_NS><stream:features>$MECHANISMS</stream:features></body>');
		notNull(features);
		isTrue(stream.ready);
	}

	function test_session_creation_failed() {
		stream.start(f -> {});
		respond('<body type="terminate" condition="host-unknown" $BODY_NS/>');
		isNull(bosh.sid);
		same(['host-unknown'], errors);
		equals(1, ended);
		equals(0, http.length);
		isFalse(stream.ready);
	}

	function test_invalid_session_creation_response() {
		stream.start(f -> {});
		respond('<body $BODY_NS/>');
		isNull(bosh.sid);
		equals(1, errors.length);
		equals(1, ended);
	}

	function test_invalid_response() {
		connect();
		respond("<html>Bad Gateway</html>");
		isNull(bosh.sid);
		same(['invalid response'], errors);
		equals(1, ended);
	}

	function test_authentication_restart() {
		login();
		equals('juliet@example.com/balcony', stream.jid);
	}

	function test_restart_request() {
		connect();
		stream.saslAuthentication('juliet', 'secret', new sasl.PlainMechanism(), (?e, f) -> {});
		// the auth was sent as a second request, the held empty one is still pending
		equals(2, http.length);
		equals(2, bosh.pending);
		final auth = http[1].body.firstElement;
		equals('auth', auth.name);
		equals('urn:ietf:params:xml:ns:xmpp-sasl', auth.ns);
		// the connection manager responds to the held request first
		respondEmpty();
		equals(1, http.length);
		respond('<body $BODY_NS><success xmlns="urn:ietf:params:xml:ns:xmpp-sasl"/></body>');
		equals(1, http.length);
		final restart = http[0].body;
		equals('true', restart.get('xmpp:restart'));
		equals(BOSH.XMLNS_XBOSH, restart.get('xmlns:xmpp'));
		equals('example.com', restart.get('to'));
		equals('en', restart.get('xml:lang'));
		equals(SID, restart.get('sid'));
		equals(0, restart.elements.length);
		isFalse(stream.ready);
		respond('<body $BODY_NS><stream:features><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"/></stream:features></body>');
		isTrue(stream.ready);
	}

	function test_send_and_receive() {
		login();
		final received = [];
		stream.onMessage = m -> received.push(m.body);

		// sent as a second request, the empty request is held
		stream.send(XML.fromString("<message to='romeo@example.com'><body>hi</body></message>"));
		equals(2, http.length);
		final body = http[1].body;
		equals(1, body.elements.length);
		equals('message', body.firstElement.name);
		equals('jabber:client', body.firstElement.ns, 'stanzas are qualified by the stream namespace');
		equals('hi', body.firstElement.firstElement.text);

		// at the request limit further payloads are queued and sent after a response
		stream.send(XML.fromString("<message to='romeo@example.com'><body>1</body></message>"));
		stream.send(XML.fromString("<message to='romeo@example.com'><body>2</body></message>"));
		equals(2, http.length);
		respondEmpty();
		equals(2, http.length);
		equals(2, http[1].body.elements.length, 'queued payloads are sent in one request');
		equals('1', http[1].body.elements[0].firstElement.text);
		equals('2', http[1].body.elements[1].firstElement.text);
		// acknowledgement of the last response, since a previous request is still pending
		equals(Std.parseInt(http[0].body.get('rid')) - 1, Std.parseInt(http[1].body.get('ack')));

		respond('<body $BODY_NS><message from="romeo@example.com" xmlns="jabber:client"><body>hey</body></message><message from="romeo@example.com"><body>unqualified</body></message></body>');
		same(['hey', 'unqualified'], received);
		equals(1, http.length);
		respondEmpty();
		equals(1, http.length, 'the session is kept alive with one pending request');
		equals(0, http[0].body.elements.length);
		isFalse(http[0].body.has('ack'), 'no acknowledgement if all previous requests were responded to');
	}

	function test_rid_sequence() {
		login();
		var rid = Std.parseInt(http[0].body.get('rid'));
		for (i in 0...3) {
			stream.send(XML.fromString("<presence/>"));
			respondEmpty();
			respondEmpty();
			equals(rid + 2 * i + 1, Std.parseInt(http[0].body.get('rid')));
			equals(rid + 2 * i + 2, Std.parseInt(http[1].body.get('rid')));
			rid += 2;
		}
	}

	function test_responses_in_request_order() {
		login();
		final received = [];
		stream.onMessage = m -> received.push(m.body);
		stream.send(XML.fromString("<presence/>"));
		equals(2, http.length);
		// the response to the later request arrives first
		final first = http[0];
		final second = http[1];
		second.onResponse('<body $BODY_NS><message xmlns="jabber:client"><body>2</body></message></body>');
		same([], received);
		first.onResponse('<body $BODY_NS><message xmlns="jabber:client"><body>1</body></message></body>');
		same(['1', '2'], received);
	}

	function test_terminate_by_client() {
		login();
		stream.send(XML.fromString("<presence type='unavailable'/>"));
		respondEmpty();
		// held + payload: both requests pending
		equals(2, http.length);
		stream.end();
		equals(3, http.length, 'the termination request exceeds the request limit');
		final body = http[2].body;
		equals('terminate', body.get('type'));
		equals(SID, body.get('sid'));
		equals(0, ended);
		// responses to the other requests
		respondEmpty();
		respondEmpty();
		equals(0, ended);
		equals(1, http.length);
		respond('<body type="terminate" $BODY_NS/>');
		equals(1, ended);
		isNull(bosh.sid);
		equals(0, http.length);
		same([], errors);
		isFalse(stream.ready);
	}

	function test_terminate_with_payload() {
		login();
		respondEmpty();
		// the unavailable presence is queued (request limit) and sent with the termination
		stream.send(XML.fromString("<presence type='unavailable'/>"));
		stream.send(XML.fromString("<presence type='unavailable'/>"));
		stream.end();
		final body = http[http.length - 1].body;
		equals('terminate', body.get('type'));
		equals(1, body.elements.length);
		equals('presence', body.firstElement.name);
		equals('jabber:client', body.firstElement.ns);
	}

	function test_terminate_acknowledged_on_other_request() {
		login();
		stream.end();
		equals(2, http.length);
		// the acknowledgement arrives on the held request, the termination request gets an empty response
		respond('<body type="terminate" $BODY_NS/>');
		equals(1, ended);
		isNull(bosh.sid);
		// the late response is ignored
		respondEmpty();
		equals(1, ended);
		equals(0, http.length);
	}

	function test_terminate_without_acknowledgement() {
		login();
		stream.end();
		respondEmpty();
		equals(0, ended);
		respondEmpty();
		equals(1, ended, 'the session ends once all requests are responded to');
	}

	function test_terminate_before_session() {
		stream.start(f -> {});
		stream.end();
		equals(1, http.length);
		sessionResponse();
		equals(1, http.length);
		equals('terminate', http[0].body.get('type'));
		respond('<body type="terminate" $BODY_NS/>');
		equals(1, ended);
		isNull(bosh.sid);
	}

	function test_terminate_by_connection_manager() {
		login();
		final received = [];
		stream.onMessage = m -> received.push(m.body);
		respond('<body type="terminate" condition="policy-violation" $BODY_NS><message xmlns="jabber:client"><body>bye</body></message></body>');
		same(['bye'], received, 'payloads are delivered before the stream ends');
		same(['policy-violation'], errors);
		equals(1, ended);
		isNull(bosh.sid);
		equals(0, http.length);
		isFalse(stream.ready);
		// nothing is sent any more
		stream.send(XML.fromString("<presence/>"));
		equals(0, http.length);
	}

	function test_remote_stream_error() {
		login();
		var nonza:XML = null;
		stream.onNonza = xml -> {
			nonza = xml;
			return false;
		}
		respond('<body type="terminate" condition="remote-stream-error" $BODY_NS><stream:error><conflict xmlns="urn:ietf:params:xml:ns:xmpp-streams"/></stream:error></body>');
		notNull(nonza);
		equals('stream:error', nonza.name);
		equals('conflict', nonza.firstElement.name);
		same(['remote-stream-error'], errors);
		equals(1, ended);
		equals(0, http.length, 'the stream end caused by the error does not send a termination');
	}

	function test_see_other_uri() {
		login();
		respond('<body type="terminate" condition="see-other-uri" uri="https://other.example.com/http-bind" $BODY_NS/>');
		equals('https://other.example.com/http-bind', redirected);
		same([], errors);
		equals(1, ended);
		isNull(bosh.sid);
	}

	function test_new_session_after_end() {
		login();
		stream.end();
		respond('<body type="terminate" $BODY_NS/>');
		respondEmpty();
		equals(1, ended);
		equals(0, http.length);
		stream.start(f -> {});
		equals(1, http.length);
		isFalse(http[0].body.has('sid'));
		equals('example.com', http[0].body.get('to'));
		respond('<body sid="OtherSID" $BODY_NS><stream:features>$MECHANISMS</stream:features></body>');
		equals('OtherSID', bosh.sid);
		isTrue(stream.ready);
	}

	function test_request_error_retry() {
		login();
		final r = http.shift();
		r.onError('Failed to connect');
		equals(1, http.length, 'the request is repeated');
		equals(r.body.toString(), http[0].body.toString());
		equals(1, bosh.pending);
		http.shift().onError('Failed to connect');
		equals(1, http.length);
		same([], errors);
		http.shift().onError('Failed to connect');
		equals(0, http.length, 'given up after the retries');
		same(['Failed to connect'], errors);
		equals(1, ended);
		isNull(bosh.sid);
	}

	function test_request_error_retry_limit() {
		bosh.retries = 0;
		login();
		http.shift().onError('Http Error #502');
		equals(0, http.length);
		same(['Http Error #502'], errors);
		equals(1, ended);
	}

	function test_repeated_request_response() {
		login();
		final received = [];
		stream.onMessage = m -> received.push(m.body);
		final r = http.shift();
		r.onError('Failed to connect');
		// the original request is answered after all, the repetition is answered with the buffered response
		r.onResponse('<body $BODY_NS><message xmlns="jabber:client"><body>once</body></message></body>');
		same(['once'], received);
		final repeated = http.shift();
		repeated.onResponse('<body $BODY_NS><message xmlns="jabber:client"><body>once</body></message></body>');
		same(['once'], received, 'the duplicate response is ignored');
		equals(1, http.length);
	}

	function test_recoverable_error() {
		login();
		stream.send(XML.fromString("<presence/>"));
		equals(2, http.length);
		final first = http[0];
		final second = http[1];
		http = [];
		second.onResponse('<body type="error" $BODY_NS/>');
		equals(2, http.length, 'the request and the preceding ones are repeated');
		equals(first.body.toString(), http[0].body.toString());
		equals(second.body.toString(), http[1].body.toString());
		equals(2, bosh.pending);
		same([], errors);
		// the original request is answered with a recoverable error too, the repetition with the response
		first.onResponse('<body type="error" $BODY_NS/>');
		equals(2, http.length, 'not repeated while a repetition is outstanding');
		respondEmpty();
		respondEmpty();
		equals(1, http.length);
		same([], errors);
	}

	function test_recoverable_error_limit() {
		bosh.retries = 1;
		login();
		respond('<body type="error" $BODY_NS/>');
		equals(1, http.length);
		respond('<body type="error" $BODY_NS/>');
		equals(0, http.length);
		same(['error'], errors);
		equals(1, ended);
	}

	function test_report() {
		login();
		stream.send(XML.fromString("<presence/>"));
		final lost = http.shift();
		lost.onError('Failed to connect');
		final repeated = http.shift();
		repeated.onError('Failed to connect');
		http = [];
		// nothing outstanding for the lost request, the connection manager reports the missing acknowledgement
		respond("<body report='" + lost.body.get('rid') + '" time="852" $BODY_NS/>');
		equals(1, http.length);
		equals(lost.body.toString(), http[0].body.toString());
	}

	function test_pause_resume() {
		login();
		isFalse(bosh.pause(200), 'longer than maxpause');
		isFalse(bosh.paused);
		isTrue(bosh.pause(60));
		isTrue(bosh.paused);
		equals(2, http.length);
		equals('60', http[1].body.get('pause'));
		equals(0, http[1].body.elements.length);
		// the connection manager responds to all requests, no new one is made
		respondEmpty();
		respondEmpty();
		equals(0, http.length);
		stream.send(XML.fromString("<presence/>"));
		equals(0, http.length, 'queued while paused');
		bosh.resume();
		isFalse(bosh.paused);
		equals(1, http.length);
		equals('presence', http[0].body.firstElement.name);
		respondEmpty();
		equals(1, http.length, 'the session is kept alive again');
		equals(0, http[0].body.elements.length);
	}

	function test_pause_not_supported() {
		stream.start(f -> {});
		respond('<body sid="$SID" wait="60" $BODY_NS><stream:features>$MECHANISMS</stream:features></body>');
		isNull(bosh.maxpause);
		isFalse(bosh.pause(10));
		isFalse(bosh.paused);
		equals(1, http.length);
	}

	function test_resume_idle() {
		login();
		isTrue(bosh.pause(60));
		respondEmpty();
		respondEmpty();
		bosh.resume();
		equals(1, http.length);
		equals(0, http[0].body.elements.length);
	}

	function test_polling_session() {
		bosh.hold = 0;
		stream.start(f -> {});
		equals('0', http[0].body.get('hold'));
		respond('<body sid="$SID" wait="60" hold="0" requests="1" polling="5" inactivity="30" $BODY_NS><stream:features>$MECHANISMS</stream:features></body>');
		equals(0, http.length, 'no request is held');
		isTrue(bosh.poll());
		equals(1, http.length);
		equals(0, http[0].body.elements.length);
		isFalse(bosh.poll(), 'a request is pending');
		stream.send(XML.fromString("<presence/>"));
		equals(1, http.length, 'at the request limit');
		respondEmpty();
		equals(1, http.length);
		equals('presence', http[0].body.firstElement.name);
		respondEmpty();
		equals(0, http.length);
	}

	function test_poll_sends_queue() {
		login();
		stream.send(XML.fromString("<presence/>"));
		stream.send(XML.fromString("<presence/>"));
		stream.send(XML.fromString("<presence/>"));
		respondEmpty();
		respondEmpty();
		equals(1, http.length);
		respondEmpty();
		isFalse(bosh.poll());
	}

	function test_poll_without_session() {
		isFalse(bosh.poll());
		equals(0, http.length);
	}

	function test_keys() {
		bosh.keyLength = 3;
		stream.start(f -> {});
		final newkey = http[0].body.get('newkey');
		notNull(newkey);
		equals(40, newkey.length);
		isFalse(http[0].body.has('key'));
		sessionResponse();
		// K(n-1): its hash is the previous key
		var key = http[0].body.get('key');
		equals(newkey, haxe.crypto.Sha1.encode(key));
		isFalse(http[0].body.has('newkey'));
		respondEmpty();
		// K(1): the last key, sent with the first key of the next sequence
		var previous = key;
		key = http[0].body.get('key');
		equals(previous, haxe.crypto.Sha1.encode(key));
		final newkey2 = http[0].body.get('newkey');
		notNull(newkey2);
		notEquals(newkey, newkey2);
		respondEmpty();
		key = http[0].body.get('key');
		equals(newkey2, haxe.crypto.Sha1.encode(key));
		isFalse(http[0].body.has('newkey'));
	}

	function test_keys_minimum_length() {
		bosh.keyLength = 1;
		stream.start(f -> {});
		final newkey = http[0].body.get('newkey');
		sessionResponse();
		final key = http[0].body.get('key');
		notNull(key);
		equals(newkey, haxe.crypto.Sha1.encode(key));
		notNull(http[0].body.get('newkey'));
	}

	function test_no_keys() {
		login();
		isFalse(http[0].body.has('key'));
		isFalse(http[0].body.has('newkey'));
	}

	function test_whitespace_keepalive_ignored() {
		login();
		stream.output(' ');
		equals(1, http.length);
	}

	function test_stream_management() {
		login();
		final sm = new xmpp.StreamManagement(stream);
		sm.enable((?e) -> {});
		equals('enable', http[1].body.firstElement.name);
		equals(xmpp.StreamManagement.XMLNS, http[1].body.firstElement.ns);
		respondEmpty();
		respond('<body $BODY_NS><enabled xmlns="urn:xmpp:sm:3" id="sm1" resume="true"/></body>');
		isTrue(sm.enabled);
		equals('sm1', sm.id);
	}

	function test_iq_query() {
		login();
		var done = false;
		stream.get(XML.create('ping').set('xmlns', 'urn:xmpp:ping'), 'example.com', res -> switch res {
			case Result(r): done = true;
			case Error(e):
		});
		final iq = http[1].body.firstElement;
		equals('iq', iq.name);
		respondEmpty();
		respond('<body $BODY_NS><iq type="result" id="${iq.get('id')}" from="example.com" xmlns="jabber:client"/></body>');
		isTrue(done);
		equals(1, http.length);
	}
}
