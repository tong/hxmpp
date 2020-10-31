
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
        equals( get, iq.type );

		var iq = new IQ( get );
		isNull( iq.to );
        isNull( iq.from );
        isNull( iq.id );
        isNull( iq.lang );
        equals( get, iq.type );
	}

	function test_parse() {

		var iq : IQ = '<iq type="result" to="user@example.com" id="ab08a"></iq>';
		equals( IQType.result, iq.type );
		equals( 'user@example.com', iq.to );
		equals( 'ab08a', iq.id );
		isNull( iq.from );
		isNull( iq.lang );
		isNull( iq.payload );

		var iq : IQ = '<iq type="get" to="jabber.disktree.net" id="ab08a">
	<query xmlns="http://jabber.org/protocol/disco#info"/>
</iq>';
		equals( get, iq.type );
		equals( 'jabber.disktree.net', iq.to );
		equals( 'ab08a', iq.id );
		isNull( iq.from );
		isNull( iq.lang );
		equals( 'http://jabber.org/protocol/disco#info', iq.payload.get('xmlns') );
	}
	
	function test_payload() {

		var p : xmpp.IQ.Payload = 'abc';
		equals( 'abc', p.get('xmlns') );
		equals( 'query', p.name );
		
		var p = xmpp.IQ.Payload.create( 'abc', '<feature var="123"/>', 'some' );
		equals( 'abc', p.get('xmlns') );
		equals( 'some', p.name );
		equals( '123', p.elements[0].get('var') );
	}

}
