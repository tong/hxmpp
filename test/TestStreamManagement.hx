import utest.Assert.*;
import xmpp.Message;
import xmpp.Stanza;
import xmpp.StreamManagement;
import xmpp.XML;

using xmpp.client.Authentication;

class TestStreamManagement extends utest.Test {
	static inline var HEADER = "<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='s1' from='example.com' version='1.0'>";
	static inline var MECHANISMS = "<mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'><mechanism>PLAIN</mechanism></mechanisms>";
	static inline var SM = "<sm xmlns='urn:xmpp:sm:3'/>";

	var stream:xmpp.client.Stream;
	var sm:StreamManagement;
	var sent:Array<String>;
	var acked:Array<XML>;

	function setup() {
		sent = [];
		acked = [];
		stream = new xmpp.client.Stream('example.com');
		stream.output = str -> sent.push(str);
		sm = new StreamManagement(stream);
		sm.onAck = stanza -> acked.push(stanza);
		login("<bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/>" + SM);
	}

	/** Starts the stream and authenticates, binding a resource if `bind` **/
	function login(features:String, bind = true) {
		stream.start(f -> {});
		stream.recv(HEADER + '<stream:features>$MECHANISMS</stream:features>');
		if (bind)
			stream.authenticate('juliet', 'balcony', 'secret', new sasl.PlainMechanism(), (?e) -> {});
		else
			stream.saslAuthentication('juliet', 'secret', new sasl.PlainMechanism(), (?e, f) -> {});
		stream.recv("<success xmlns='urn:ietf:params:xml:ns:xmpp-sasl'/>");
		stream.recv(HEADER + '<stream:features>$features</stream:features>');
		if (bind) {
			final iq = lastSent();
			stream.recv('<iq type="result" id="${iq.get("id")}"><bind xmlns="urn:ietf:params:xml:ns:xmpp-bind"><jid>juliet@example.com/balcony</jid></bind></iq>');
		}
	}

	function enable() {
		var done = false;
		sm.enable((?e) -> done = e == null);
		stream.recv("<enabled xmlns='urn:xmpp:sm:3' id='sm1' resume='true' max='300'/>");
		isTrue(done);
	}

	function lastSent():XML
		return XML.fromString(sent[sent.length - 1]);

	function sentNames(from:Int):Array<String>
		return [for (i in from...sent.length) XML.fromString(sent[i]).name];

	function test_offered() {
		isTrue(StreamManagement.isOffered(stream.serverFeatures));
		isFalse(StreamManagement.isOffered(XML.fromString("<stream:features xmlns:stream='http://etherx.jabber.org/streams'/>")));
		isFalse(StreamManagement.isOffered(null));
	}

	function test_enable() {
		var error:xmpp.Stanza.Error = null;
		var done = false;
		sm.enable(true, 300, (?e) -> {
			done = true;
			error = e;
		});
		final xml = lastSent();
		equals('enable', xml.name);
		equals(StreamManagement.XMLNS, xml.get('xmlns'));
		equals('true', xml.get('resume'));
		equals('300', xml.get('max'));
		isTrue(sm.enabled);
		isFalse(done);
		stream.recv("<enabled xmlns='urn:xmpp:sm:3' id='sm1' resume='1' max='600' location='[2001:db8::1]:5222'/>");
		isTrue(done);
		isNull(error);
		equals('sm1', sm.id);
		equals(600, sm.max);
		equals('[2001:db8::1]:5222', sm.location);
	}

	function test_enable_not_resumable() {
		sm.enable(false, (?e) -> {});
		isNull(lastSent().get('resume'));
		stream.recv("<enabled xmlns='urn:xmpp:sm:3' id='sm1'/>");
		isTrue(sm.enabled);
		isNull(sm.id);
	}

	function test_enable_failed() {
		var error:xmpp.Stanza.Error = null;
		sm.enable((?e) -> error = e);
		stream.recv("<failed xmlns='urn:xmpp:sm:3'><unexpected-request xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/></failed>");
		equals(unexpected_request, error.condition);
		isFalse(sm.enabled);
	}

	function test_enable_not_offered() {
		stream.start(f -> {});
		stream.recv(HEADER + "<stream:features><bind xmlns='urn:ietf:params:xml:ns:xmpp-bind'/></stream:features>");
		final count = sent.length;
		var error:xmpp.Stanza.Error = null;
		sm.enable((?e) -> error = e);
		equals(feature_not_implemented, error.condition);
		equals(count, sent.length);
	}

	function test_answer_ack_requests() {
		sm.enable((?e) -> {});
		// sent by the server before <enabled/>: not counted
		stream.recv("<message from='romeo@example.net'><body>1</body></message>");
		stream.recv("<enabled xmlns='urn:xmpp:sm:3' id='sm1' resume='true'/>");
		stream.recv("<r xmlns='urn:xmpp:sm:3'/>");
		equals('a', lastSent().name);
		equals('0', lastSent().get('h'));
		stream.recv("<message from='romeo@example.net'><body>2</body></message>");
		stream.recv("<presence from='romeo@example.net'/>");
		stream.recv("<iq type='get' id='v1' from='romeo@example.net/orchard'><query xmlns='jabber:iq:version'/></iq>");
		stream.recv("<r xmlns='urn:xmpp:sm:3'/>");
		equals('3', lastSent().get('h'));
	}

	function test_request_acks() {
		enable();
		final count = sent.length;
		stream.send(new Message('romeo@example.net', '1'));
		stream.send(new Message('romeo@example.net', '2'));
		// one pending request at a time
		same(['message', 'r', 'message'], sentNames(count));
		equals(2, sm.unacked.length);

		stream.recv("<a xmlns='urn:xmpp:sm:3' h='1'/>");
		equals(1, acked.length);
		equals('1', (acked[0] : Message).body);
		equals(1, sm.unacked.length);
		// unacknowledged stanzas left: request again
		equals('r', lastSent().name);

		stream.recv("<a xmlns='urn:xmpp:sm:3' h='2'/>");
		equals(2, acked.length);
		equals(0, sm.unacked.length);
		equals('r', lastSent().name);
		equals(count + 4, sent.length);
	}

	function test_without_request_acks() {
		enable();
		sm.requestAcks = false;
		final count = sent.length;
		stream.send(new Message('romeo@example.net', '1'));
		same(['message'], sentNames(count));
		sm.requestAck();
		equals('r', lastSent().name);
		stream.recv("<a xmlns='urn:xmpp:sm:3' h='1'/>");
		equals(1, acked.length);
	}

	function test_nonzas_not_counted() {
		enable();
		final count = sent.length;
		stream.send(XML.create('inactive').set('xmlns', 'urn:xmpp:csi:0'));
		same(['inactive'], sentNames(count));
		equals(0, sm.unacked.length);
	}

	function test_handled_count_too_high() {
		enable();
		stream.send(new Message('romeo@example.net', '1'));
		stream.recv("<a xmlns='urn:xmpp:sm:3' h='2'/>");
		final error = XML.fromString(sent[sent.length - 2]);
		equals('stream:error', error.name);
		final c = error.elements.named('handled-count-too-high')[0];
		equals('2', c.get('h'));
		equals('1', c.get('send-count'));
		equals('</stream:stream>', sent[sent.length - 1]);
		isFalse(stream.ready);
		equals(0, acked.length);
	}

	function test_resume() {
		enable();
		stream.recv("<message from='romeo@example.net'><body>in</body></message>");
		stream.send(new Message('romeo@example.net', '1'));
		var response:xmpp.Response<XML> = null;
		final iq = stream.get('jabber:iq:version', 'romeo@example.net/orchard', r -> response = r);
		stream.send(new Message('romeo@example.net', '2'));

		// disconnected, reconnect without binding a resource
		login(MECHANISMS + SM, false);
		isNull(stream.jid);
		isFalse(sm.enabled);
		var done = false;
		var error:xmpp.Stanza.Error = null;
		sm.resume((?e, ?unacked) -> {
			done = true;
			error = e;
		});
		final xml = lastSent();
		equals('resume', xml.name);
		equals('1', xml.get('h'));
		equals('sm1', xml.get('previd'));

		final count = sent.length;
		stream.recv("<resumed xmlns='urn:xmpp:sm:3' h='1' previd='sm1'/>");
		isTrue(done);
		isNull(error);
		equals('juliet@example.com/balcony', stream.jid);
		isTrue(sm.enabled);
		equals(1, acked.length);
		// unacknowledged stanzas resent
		same(['iq', 'r', 'message'], sentNames(count));
		equals(iq.id, XML.fromString(sent[count]).get('id'));
		equals(2, sm.unacked.length);

		// response to the request sent before the disconnection
		stream.recv('<iq type="result" id="${iq.id}" from="romeo@example.net/orchard"><query xmlns="jabber:iq:version"/></iq>');
		notNull(response);
		isTrue(response.ok());

		// counting continues: the response and the message
		stream.recv("<message from='romeo@example.net'><body>in</body></message>");
		stream.recv("<r xmlns='urn:xmpp:sm:3'/>");
		equals('3', lastSent().get('h'));
	}

	function test_resume_failed() {
		enable();
		stream.send(new Message('romeo@example.net', '1'));
		stream.send(new Message('romeo@example.net', '2'));
		login(MECHANISMS + SM, false);
		var error:xmpp.Stanza.Error = null;
		var unacked:Array<XML> = null;
		sm.resume((?e, ?u) -> {
			error = e;
			unacked = u;
		});
		stream.recv("<failed xmlns='urn:xmpp:sm:3' h='1'><item-not-found xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/></failed>");
		equals(item_not_found, error.condition);
		equals(1, acked.length);
		equals(1, unacked.length);
		equals('2', (unacked[0] : Message).body);
		isNull(sm.id);
		isFalse(sm.enabled);
	}

	function test_end() {
		enable();
		stream.recv("<message from='romeo@example.net'><body>in</body></message>");
		stream.send(new Message('romeo@example.net', '1'));
		stream.end();
		// final ack before closing
		equals('a', XML.fromString(sent[sent.length - 2]).name);
		equals('1', XML.fromString(sent[sent.length - 2]).get('h'));
		isNull(sm.id);
		// the session can not be resumed
		var error:xmpp.Stanza.Error = null;
		var unacked:Array<XML> = null;
		sm.resume((?e, ?u) -> {
			error = e;
			unacked = u;
		});
		equals(item_not_found, error.condition);
		equals(1, unacked.length);
	}
}
