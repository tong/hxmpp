
import utest.Assert.*;
import xmpp.XML;
import xmpp.IQ;

class TestIQ extends utest.Test {

    function test_create() {

        var iq = new IQ();
        isNull( iq.to );
        isNull( iq.from );
        isNull( iq.id );
        isNull( iq.lang );
        equals( Get, iq.type );

		var iq = new IQ( Get );
		isNull( iq.to );
        isNull( iq.from );
        isNull( iq.id );
        isNull( iq.lang );
        equals( Get, iq.type );
	}

	function test_parse() {

		var iq : IQ = XML.parse('<iq type="result" to="user@example.com" id="ab08a"></iq>').firstElement;
		equals( IQType.Result, iq.type );
		equals( 'user@example.com', iq.to );
		equals( 'ab08a', iq.id );
		isNull( iq.from );
		isNull( iq.lang );
		isNull( iq.payload );

		var iq : IQ = XML.parse('<iq type="get" to="jabber.disktree.net" id="ab08a">
	<query xmlns="http://jabber.org/protocol/disco#info"/>
</iq>').firstElement;
		equals( Get, iq.type );
		equals( 'jabber.disktree.net', iq.to );
		equals( 'ab08a', iq.id );
		isNull( iq.from );
		isNull( iq.lang );
		equals( 'http://jabber.org/protocol/disco#info', iq.payload.get('xmlns') );
	}
	
	function test_payload() {

		var p : xmpp.IQ.Payload = 'abc';
		equals("query", p.name);
		equals("abc", p.get('xmlns'));
		equals(0, p.elements.length);

		//var p = Payload.create('abc', XML.create('feature', ["var"=>"123"]), 'some');
		var p = Payload.create("abc", "some");
		equals("some", p.name);
		equals("abc", p.xmlns);
		equals(0, p.elements.length);
		isNull(p.content);
		
        var p : Payload = Payload.create("abc", "some").append(XML.create("child","data"));
		equals("some", p.name);
		equals("abc", p.xmlns);
		equals(1, p.elements.length);
		equals("child", p.content.name);
		equals("data", p.content.text);
	}

}
