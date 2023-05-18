
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
		equals('query', p.name);
		equals('abc', p.get('xmlns'));
		equals(0, p.elements.length);
		
		// var p : Payload = Payload.create('abc', '<feature var="123"/>', 'some');
		// equals('some', p.name);
		// equals('abc', p.xmlns);
  //       trace(p.elements);
  //       for(e in p.elements) trace(e);
		//equals( 'feature', p.elements[0].name );
        
		//equals( '123', p.elements[0].get('var') );
  //       var xml = XML.create("query", ["xmlns"=>"some-xmlns"]);
  //       xml.append(XML.create('feature', ["var"=>"123"]));
		// equals('query', xml.name);
		// equals('some-xmlns', xml.get('xmlns'));
		// equals(1, xml.elements.length);

		var p = Payload.create('abc', XML.create('feature', ["var"=>"123"]), 'some');
		equals('some',p.name);
		equals('abc', p.xmlns);
		equals(1, p.elements.length);
		equals('feature', p.elements[0].name);
		equals('123', p.elements[0]["var"]);
	}

}
