import haxe.crypto.Base64;
import haxe.io.Bytes;
import utest.Assert.*;
import xmpp.Stanza;
import xmpp.XML;
import xmpp.client.Authentication;
import xmpp.client.StateIndication;

using xmpp.client.Authentication;

class TestAuthentication extends utest.Test {
	static inline var HEADER = "<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='s1' from='example.com' version='1.0'>";
	static inline var SUCCESS = "<success xmlns='urn:ietf:params:xml:ns:xmpp-sasl'/>";

	var stream:xmpp.client.Stream;
	var sent:Array<String>;
	var done:Bool;
	var error:Null<xmpp.Stanza.Error>;

	function setup() {
		sent = [];
		done = false;
		error = null;
		stream = new xmpp.client.Stream('example.com');
		stream.output = str -> sent.push(str);
		stream.start(features -> {});
		stream.recv(HEADER + "<stream:features><mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'><mechanism>PLAIN</mechanism></mechanisms></stream:features>");
	}

	function authenticate(?resource:String) {
		stream.authenticate('juliet', resource, 'secret', new sasl.PlainMechanism(), (?e) -> {
			done = true;
			error = e;
		});
	}

	function lastSent():XML
		return XML.fromString(sent[sent.length - 1]);

	function restart(features:String) {
		stream.recv(SUCCESS);
		stream.recv(HEADER + '<stream:features>$features</stream:features>');
	}

	function replyBind() {
		final iq = lastSent();
		equals('iq', iq.name);
		equals('bind', iq.firstElement.name);
		stream.recv('<iq type="result" id="${iq.get("id")}"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"><jid>juliet@example.com/balcony</jid></bind></iq>');
	}

	function test_features() {
		var features:XML = null;
		final stream = new xmpp.client.Stream('example.com');
		stream.output = str -> {};
		stream.start(f -> features = f);
		stream.recv(HEADER + "<stream:features><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/></stream:features>");
		equals('stream:features', features.name);
		equals('bind', features.firstElement.name);
	}

	function test_without_session() {
		authenticate('balcony');
		restart("<bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/>");
		replyBind();
		isTrue(done);
		isNull(error);
		equals('juliet@example.com/balcony', stream.jid);
	}

	function test_optional_session() {
		authenticate('balcony');
		restart("<bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/><session xmlns='urn:ietf:params:xml:ns:xmpp-session'><optional/></session>");
		replyBind();
		isTrue(done);
		isNull(error);
		equals('bind', lastSent().firstElement.name);
	}

	function test_required_session() {
		authenticate('balcony');
		restart("<bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/><session xmlns='urn:ietf:params:xml:ns:xmpp-session'/>");
		replyBind();
		isFalse(done);
		final iq = lastSent();
		equals('session', iq.firstElement.name);
		stream.recv('<iq type="result" id="${iq.get("id")}"/>');
		isTrue(done);
		isNull(error);
	}

	function test_server_generated_resource() {
		authenticate();
		restart("<bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/>");
		equals(0, lastSent().firstElement.elements.count());
		replyBind();
		isTrue(done);
		isNull(error);
	}

	function test_sasl_failure() {
		authenticate('balcony');
		stream.recv("<failure xmlns='urn:ietf:params:xml:ns:xmpp-sasl'><not-authorized/><text>Invalid credentials</text></failure>");
		isTrue(done);
		equals(not_authorized, error.condition);
		equals(auth, error.type);
		equals('Invalid credentials', error.text);
	}

	function test_sasl_stream_error() {
		authenticate('balcony');
		stream.recv("<stream:error><policy-violation xmlns='urn:ietf:params:xml:ns:xmpp-streams'/></stream:error>");
		isTrue(done);
		equals('policy-violation', error.condition);
		equals(cancel, error.type);
	}

	function test_invalid_bind_response() {
		authenticate('balcony');
		restart("<bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/>");
		final iq = lastSent();
		stream.recv('<iq type="result" id="${iq.get("id")}"/>');
		isTrue(done);
		equals(undefined_condition, error.condition);
	}

	// https://www.rfc-editor.org/rfc/rfc5802#section-5
	static inline var SCRAM_CNONCE = 'fyko+d2lbbFgONRv9qkxdawL';
	static inline var SCRAM_SERVER_FIRST = 'r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,s=QSXCR+Q6sek8bf92,i=4096';
	static inline var SCRAM_SERVER_FINAL = 'v=rmF9pqV8S7suAoZWja4dJRkFsKQ=';

	static function b64(s:String):String
		return Base64.encode(Bytes.ofString(s));

	function authenticateScram() {
		stream.authenticate('user', 'balcony', 'pencil', new sasl.SCRAMSHA1Mechanism(SCRAM_CNONCE), (?e) -> {
			done = true;
			error = e;
		});
		final auth = lastSent();
		equals('SCRAM-SHA-1', auth.get('mechanism'));
		equals(b64('n,,n=user,r=$SCRAM_CNONCE'), auth.text);
	}

	function test_scram() {
		authenticateScram();
		stream.recv('<challenge xmlns="urn:ietf:params:xml:ns:xmpp-sasl">${b64(SCRAM_SERVER_FIRST)}</challenge>');
		final response = lastSent();
		equals('response', response.name);
		equals(b64('c=biws,r=fyko+d2lbbFgONRv9qkxdawL3rfcNHYJY1ZVvWVs7j,p=v0X8v3Bz2T0CJGbJQyF0X+HI4Ts='), response.text);
		stream.recv('<success xmlns="urn:ietf:params:xml:ns:xmpp-sasl">${b64(SCRAM_SERVER_FINAL)}</success>');
		isFalse(done);
		isTrue(StringTools.startsWith(sent[sent.length - 1], '<stream:stream'));
		stream.recv(HEADER + "<stream:features><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/></stream:features>");
		replyBind();
		isTrue(done);
		isNull(error);
	}

	function test_scram_invalid_server_signature() {
		authenticateScram();
		stream.recv('<challenge xmlns="urn:ietf:params:xml:ns:xmpp-sasl">${b64(SCRAM_SERVER_FIRST)}</challenge>');
		final count = sent.length;
		stream.recv('<success xmlns="urn:ietf:params:xml:ns:xmpp-sasl">${b64("v=AAAAAAAAAAAAAAAAAAAAAAAAAAA=")}</success>');
		isTrue(done);
		equals(not_authorized, error.condition);
		// the stream is not restarted
		equals(count, sent.length);
	}

	function test_scram_missing_server_signature() {
		authenticateScram();
		stream.recv('<challenge xmlns="urn:ietf:params:xml:ns:xmpp-sasl">${b64(SCRAM_SERVER_FIRST)}</challenge>');
		stream.recv(SUCCESS);
		isTrue(done);
		equals(not_authorized, error.condition);
	}

	function test_scram_invalid_challenge() {
		authenticateScram();
		stream.recv('<challenge xmlns="urn:ietf:params:xml:ns:xmpp-sasl">${b64("r=othernonce,s=QSXCR+Q6sek8bf92,i=4096")}</challenge>');
		equals('abort', lastSent().name);
		isFalse(done);
		stream.recv("<failure xmlns='urn:ietf:params:xml:ns:xmpp-sasl'><aborted/></failure>");
		isTrue(done);
		equals(not_authorized, error.condition);
		notNull(error.text);
	}

	function test_select_mechanism() {
		function features(mechanisms:Array<String>):XML
			return XML.fromString("<stream:features xmlns:stream='http://etherx.jabber.org/streams'><mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'>"
				+ [for (m in mechanisms) '<mechanism>$m</mechanism>'].join('') + "</mechanisms></stream:features>");

		equals('SCRAM-SHA-1,SCRAM-SHA-256,PLAIN', Authentication.getMechanisms(features(['SCRAM-SHA-1', 'SCRAM-SHA-256', 'PLAIN'])).join(','));
		equals(0, Authentication.getMechanisms(null).length);

		equals('SCRAM-SHA-256', Authentication.selectMechanism(features(['SCRAM-SHA-1', 'SCRAM-SHA-256', 'PLAIN'])).name);
		equals('SCRAM-SHA-1', Authentication.selectMechanism(features(['PLAIN', 'SCRAM-SHA-1'])).name);
		isNull(Authentication.selectMechanism(features(['PLAIN'])));
		equals('PLAIN', Authentication.selectMechanism(features(['PLAIN']), true).name);
		isNull(Authentication.selectMechanism(features(['DIGEST-MD5'])));
		isNull(Authentication.selectMechanism(null));
	}

	function test_stream_error_condition() {
		authenticate('balcony');
		stream.recv("<stream:error><conflict xmlns='urn:ietf:params:xml:ns:xmpp-streams'/><text xmlns='urn:ietf:params:xml:ns:xmpp-streams'>Replaced by new connection</text><escape-your-data xmlns='application-ns'/></stream:error>");
		equals('conflict', (error.condition : String));
		equals('Replaced by new connection', error.text);
	}

	function test_sasl_failure_condition() {
		// https://xmpp.org/rfcs/rfc6120.html#sasl-errors-account-disabled
		authenticate('balcony');
		stream.recv("<failure xmlns='urn:ietf:params:xml:ns:xmpp-sasl'><account-disabled/><text xml:lang='en'>Call 212-555-1212 for assistance.</text></failure>");
		equals('account-disabled', (error.condition : String));
		equals('Call 212-555-1212 for assistance.', error.text);

		authenticate('balcony');
		stream.recv("<failure xmlns='urn:ietf:params:xml:ns:xmpp-sasl'><text>no condition</text></failure>");
		equals(undefined_condition, error.condition);
	}

	function test_empty_initial_response() {
		final mechanism:sasl.Mechanism = new EmptyResponseMechanism();
		stream.authenticate('juliet', 'balcony', 'secret', mechanism, (?e) -> {});
		equals('=', lastSent().text);
	}

	function test_server_features() {
		// pre-auth features
		isTrue(stream.serverFeatures.elements.findElement('mechanisms') != null);
		authenticate('balcony');
		restart("<bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/><csi xmlns='urn:xmpp:csi:0'/>");
		replyBind();
		isTrue(done);
		isTrue(StateIndication.isOffered(stream.serverFeatures));
	}

	function test_csi() {
		isFalse(StateIndication.isOffered(null));
		// pre-auth features without csi: nothing is sent
		final count = sent.length;
		isNull(StateIndication.setInactive(stream));
		equals(count, sent.length);

		authenticate('balcony');
		restart("<bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/><csi xmlns='urn:xmpp:csi:0'/>");
		replyBind();
		StateIndication.setInactive(stream);
		equals('inactive', lastSent().name);
		equals(StateIndication.XMLNS, lastSent().get('xmlns'));
		StateIndication.setActive(stream);
		equals('active', lastSent().name);
	}
}

private class EmptyResponseMechanism implements sasl.Mechanism {
	public final name = 'X-EMPTY';

	public function new() {}

	public function createAuthenticationText(username:String, host:String, password:String):String
		return '';

	public function createChallengeResponse(challenge:String):String
		return null;

	public function verifySuccess(data:String):Bool
		return true;

	public function handleAuthenticationText(text:String):Array<String>
		return null;
}
