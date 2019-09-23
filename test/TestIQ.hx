
import utest.Assert.*;
import xmpp.XML;
import xmpp.IQ;

class TestIQ extends utest.Test {

    function test_create() {

        var iq = new IQ();
        equals( null, iq.to );
        equals( null, iq.from );
        equals( null, iq.id );
        equals( null, iq.lang );
        equals( get, iq.type );

		var iq = new IQ( get );
		equals( null, iq.to );
        equals( null, iq.from );
        equals( null, iq.id );
        equals( null, iq.lang );
        equals( get, iq.type );
	}

	function test_parse() {

		var iq : IQ = '<iq type="result" to="user@example.com" id="ab08a"></iq>';
		equals( result, iq.type );
		equals( 'user@example.com', iq.to );
		equals( 'ab08a', iq.id );
		equals( null, iq.from );
		equals( null, iq.lang );
		equals( null, iq.content );

		var iq : IQ = '<iq type="get" to="jabber.disktree.net" id="ab08a">
	<query xmlns="http://jabber.org/protocol/disco#info"/>
</iq>';
		equals( get, iq.type );
		equals( 'jabber.disktree.net', iq.to );
		equals( 'ab08a', iq.id );
		equals( null, iq.from );
		equals( null, iq.lang );
		equals( 'http://jabber.org/protocol/disco#info', iq.content.get('xmlns') );
	}

}
