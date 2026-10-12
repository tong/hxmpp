import utest.Assert.*;
import xmpp.XML;
import xmpp.IQ;
import xmpp.Stanza;

class TestIQ extends utest.Test {
	function test_create() {
		var iq = new IQ();
		isNull(iq.to);
		isNull(iq.from);
		isNull(iq.id);
		isNull(iq.lang);
		equals(Get, iq.type);

		var iq = new IQ(Get);
		isNull(iq.to);
		isNull(iq.from);
		isNull(iq.id);
		isNull(iq.lang);
		equals(Get, iq.type);
	}

	function test_parse() {
		var iq:IQ = XML.fromString('<iq type="result" to="user@example.com" id="ab08a"></iq>');
		equals(IQType.Result, iq.type);
		equals('user@example.com', iq.to);
		equals('ab08a', iq.id);
		isNull(iq.from);
		isNull(iq.lang);
		isNull(iq.payload);

		var iq:IQ = XML.fromString('<iq type="get" to="jabber.disktree.net" id="ab08a">
	<query xmlns="http://jabber.org/protocol/disco#info"/>
</iq>');
		equals(Get, iq.type);
		equals('jabber.disktree.net', iq.to);
		equals('ab08a', iq.id);
		isNull(iq.from);
		isNull(iq.lang);
		equals('http://jabber.org/protocol/disco#info', iq.payload.get('xmlns'));
	}

	function test_fromString() {
		var iq = IQ.fromString('<iq type="get" id="ab08a"><query xmlns="jabber:iq:roster"/></iq>');
		equals(Get, iq.type);
		equals('ab08a', iq.id);
		equals('jabber:iq:roster', iq.payload.xmlns);

		var iq:IQ = '<iq type="result" id="xyz"/>';
		equals(Result, iq.type);
		equals('xyz', iq.id);
	}

	function test_parse_error() {
		var iq:IQ = '<iq type="error" id="e1"><error type="cancel"><item-not-found xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></iq>';
		equals(IQType.Error, iq.type);
		equals(item_not_found, iq.error.condition);
		equals(cancel, iq.error.type);
		isNull(iq.payload);

		var iq:IQ = '<iq type="error" id="e2"><query xmlns="jabber:iq:roster"/><error type="auth"><forbidden xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error></iq>';
		equals(forbidden, iq.error.condition);
		equals(auth, iq.error.type);
		equals('jabber:iq:roster', iq.payload.xmlns);
	}

	function test_payload() {
		var p:xmpp.IQ.Payload = 'abc';
		equals("query", p.name);
		equals("abc", p.get('xmlns'));
		equals(0, p.elements.length);

		// var p = Payload.create('abc', XML.create('feature', ["var"=>"123"]), 'some');
		var p = Payload.create("abc", "some");
		equals("some", p.name);
		equals("abc", p.xmlns);
		equals(0, p.elements.length);
		isNull(p.content);

		var p:Payload = Payload.create("abc", "some").append(XML.create("child", "data"));
		equals("some", p.name);
		equals("abc", p.xmlns);
		equals(1, p.elements.length);
		equals("child", p.content.name);
		equals("data", p.content.text);
	}
}
