import utest.Assert.*;
import xmpp.StartTLS;
import xmpp.XML;

class TestStartTLS extends utest.Test {
	function test_features() {
		final features = XML.fromString("<stream:features xmlns:stream='http://etherx.jabber.org/streams'><starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/><mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'><mechanism>SCRAM-SHA-1</mechanism></mechanisms></stream:features>");
		isTrue(StartTLS.isOffered(features));
		isFalse(StartTLS.isRequired(features));

		final required = XML.fromString("<stream:features xmlns:stream='http://etherx.jabber.org/streams'><starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'><required/></starttls></stream:features>");
		isTrue(StartTLS.isOffered(required));
		isTrue(StartTLS.isRequired(required));

		final none = XML.fromString("<stream:features xmlns:stream='http://etherx.jabber.org/streams'><mechanisms xmlns='urn:ietf:params:xml:ns:xmpp-sasl'/></stream:features>");
		isFalse(StartTLS.isOffered(none));
		isFalse(StartTLS.isRequired(none));
		isFalse(StartTLS.isOffered(null));
	}

	function test_start_tls() {
		function negotiate(response:String):Null<Bool> {
			final stream = new xmpp.client.Stream('example.com');
			final sent = new Array<String>();
			stream.output = str -> sent.push(str);
			var result:Null<Bool> = null;
			stream.start(features -> StartTLS.startTLS(stream, success -> result = success));
			stream.recv("<stream:stream xmlns='jabber:client' xmlns:stream='http://etherx.jabber.org/streams' id='abc' from='example.com' version='1.0'><stream:features><starttls xmlns='urn:ietf:params:xml:ns:xmpp-tls'/></stream:features>");
			equals('starttls', XML.fromString(sent[sent.length - 1]).name);
			stream.recv(response);
			return result;
		}
		isTrue(negotiate("<proceed xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>"));
		isFalse(negotiate("<failure xmlns='urn:ietf:params:xml:ns:xmpp-tls'/>"));
		isFalse(negotiate("<stream:error><internal-server-error xmlns='urn:ietf:params:xml:ns:xmpp-streams'/></stream:error>"));
	}
}
