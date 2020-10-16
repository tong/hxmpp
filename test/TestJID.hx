
import utest.Assert.*;
import xmpp.JID;

class TestJID extends utest.Test {

    function test_ereg() {

		isTrue( JID.EREG.match( 'node@domain.net/Resource' ) );
		equals( 'node@domain.net/Resource', JID.EREG.matched( 1 ) );
		equals( 'node', JID.EREG.matched( 2 ) );
		equals( 'domain.net', JID.EREG.matched( 3 ) );
		equals( '/Resource', JID.EREG.matched( 4 ) );
		equals( 'Resource', JID.EREG.matched( 5 ) );

		isTrue( JID.EREG.match( 'node@domain/Resource' ) );
		equals( 'node@domain/Resource', JID.EREG.matched( 1 ) );
		equals( 'node', JID.EREG.matched( 2 ) );
		equals( 'domain', JID.EREG.matched( 3 ) );
		equals( '/Resource', JID.EREG.matched( 4 ) );
		equals( 'Resource', JID.EREG.matched( 5 ) );

		isTrue( JID.EREG.match( 'node@domain' ) );
		equals( 'node@domain', JID.EREG.matched( 1 ) );
		equals( 'node', JID.EREG.matched( 2 ) );
		equals( 'domain', JID.EREG.matched( 3 ) );
		isNull( JID.EREG.matched( 4 ) );
		isNull( JID.EREG.matched( 5 ) );
    }

	function test_validation() {

		isFalse( JID.isValid( "aaa" ) );

		isTrue( JID.isValid( "node@domain" ) );
		isTrue( JID.isValid( "node@domain/Resource" ) );
		isTrue( JID.isValid( "node@domain.net/Resource" ) );
		isTrue( JID.isValid( "node@domain.net" ) );
		isTrue( JID.isValid( "node@sub.domain.com" ) );
		isTrue( JID.isValid( "node@sub.domain.com/Resource" ) );
		isTrue( JID.isValid( "node@dd.net" ) );
	}

    function test_parse() {

        var parts = JID.parseParts( "node@domain.net/Resource" );
        equals( "node", parts[0] );
        equals( "domain.net", parts[1] );
        equals( "Resource", parts[2] );

		parts = JID.parseParts( "node@domain.net" );
        equals( "node", parts[0] );
        equals( "domain.net", parts[1] );
        isNull( parts[2] );

		equals( "node", JID.parseNode( "node@domain.net/Resource" ) );
		equals( "domain.net", JID.parseDomain( "node@domain.net/Resource" ) );
		equals( "Resource", JID.parseResource( "node@domain.net/Resource" ) );

        equals( 'domain.net', JID.parseDomain('node@domain.net/Resource') );
        equals( 'domain.net', JID.parseDomain('node@domain.net') );
        equals( 'domain', JID.parseDomain('node@domain') );

		equals( 'Resource', JID.parseResource('node@domain.net/Resource') );
        isNull( JID.parseResource('node@domain.net') );
        isNull( JID.parseResource('node@domain') );

		equals( 'node@domain.net', JID.parseBare('node@domain.net/Resource') );
        equals( 'node@domain.net', JID.parseBare('node@domain.net') );
        equals( 'node@domain', JID.parseBare('node@domain') );
    }

    function test_from() {

        var jid : JID = "node@domain.net/Resource";
        equals( "node", jid.node );
        equals( "domain.net", jid.domain );
        equals( "Resource", jid.resource );

        var jid : JID = ["node","domain.net","Resource"];
        equals( "node", jid.node );
        equals( "domain.net", jid.domain );
        equals( "Resource", jid.resource );
    }

    function test_to() {

        var jid : JID = "node@domain.net/Resource";

        var str : String = jid;
        equals( "node@domain.net/Resource", str );

        var arr : Array<String> = jid;
        equals( "node", arr[0] );
        equals( "domain.net", arr[1] );
        equals( "Resource", arr[2] );
    }

    function test_escape() {

        var str = 'joe smith"hugo&karl\\tom/che:ruth<elias>rotz@coma\\\\';
		equals( JID.unescapeNode( JID.escapeNode( str ) ), str );

        var str = '1\\202\\223\\264\\275\\2f6\\3a7\\3c8\\3e9\\4010\\5c';
		equals( "1 2\"3&4'5/6:7<8>9@10\\", JID.unescapeNode( str ) );
		equals( str, JID.escapeNode( JID.unescapeNode( str ) ) );
	}

	function testEquals() {
		
		var a = new JID( 'romeo', 'server.com', 'balcony' );
		var b = new JID( 'julia', 'host.net', 'castle' );
		isFalse( a.equals(b) );
		isFalse( a == b );
		
		var a = new JID( 'romeo', 'server.com', 'balcony' );
		var b = new JID( 'romeo', 'server.com', 'balcony' );
		isTrue( a.equals(b) );
		isTrue( a == b );
	}

	function testArrayAccess() {

		var a = new JID( 'romeo', 'server.com', 'balcony' );
		equals( 'romeo', a[0] );
		equals( 'server.com', a[1] );
		equals( 'balcony', a[2] );
		equals( 'romeo@server.com/balcony', a[3] );
		equals( 'romeo@server.com/balcony', a[999] );
		equals( 'romeo@server.com/balcony', a[-1] );

		a[0] = 'julia';
		a[1] = 'another.com';
		a[2] = 'woods';

		equals( 'julia', a[0] );
		equals( 'another.com', a[1] );
		equals( 'woods', a[2] );
		equals( 'julia@another.com/woods', a[3] );
		equals( 'julia@another.com/woods', a[999] );
		equals( 'julia@another.com/woods', a[-1] );
	}

}
