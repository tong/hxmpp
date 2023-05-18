
import utest.Assert.*;
import xmpp.Jid;

class TestJid extends utest.Test {

    function test_ereg() {

		isTrue( Jid.EREG.match( 'node@domain.net/Resource' ) );
		equals( 'node@domain.net/Resource', Jid.EREG.matched( 1 ) );
		equals( 'node', Jid.EREG.matched( 2 ) );
		equals( 'domain.net', Jid.EREG.matched( 3 ) );
		equals( '/Resource', Jid.EREG.matched( 4 ) );
		equals( 'Resource', Jid.EREG.matched( 5 ) );

		isTrue( Jid.EREG.match( 'node@domain/Resource' ) );
		equals( 'node@domain/Resource', Jid.EREG.matched( 1 ) );
		equals( 'node', Jid.EREG.matched( 2 ) );
		equals( 'domain', Jid.EREG.matched( 3 ) );
		equals( '/Resource', Jid.EREG.matched( 4 ) );
		equals( 'Resource', Jid.EREG.matched( 5 ) );

		isTrue( Jid.EREG.match( 'node@domain' ) );
		equals( 'node@domain', Jid.EREG.matched( 1 ) );
		equals( 'node', Jid.EREG.matched( 2 ) );
		equals( 'domain', Jid.EREG.matched( 3 ) );
		isNull( Jid.EREG.matched( 4 ) );
		isNull( Jid.EREG.matched( 5 ) );
    }

	function test_validation() {

		isFalse( Jid.isValid( "aaa" ) );

		isTrue( Jid.isValid( "node@domain" ) );
		isTrue( Jid.isValid( "node@domain/Resource" ) );
		isTrue( Jid.isValid( "node@domain.net/Resource" ) );
		isTrue( Jid.isValid( "node@domain.net" ) );
		isTrue( Jid.isValid( "node@sub.domain.com" ) );
		isTrue( Jid.isValid( "node@sub.domain.com/Resource" ) );
		isTrue( Jid.isValid( "node@dd.net" ) );
	}

    function test_parse() {

        var parts = Jid.parseParts( "node@domain.net/Resource" );
        equals( "node", parts[0] );
        equals( "domain.net", parts[1] );
        equals( "Resource", parts[2] );

		parts = Jid.parseParts( "node@domain.net" );
        equals( "node", parts[0] );
        equals( "domain.net", parts[1] );
        isNull( parts[2] );

		equals( "node", Jid.parseNode( "node@domain.net/Resource" ) );
		equals( "domain.net", Jid.parseDomain( "node@domain.net/Resource" ) );
		equals( "Resource", Jid.parseResource( "node@domain.net/Resource" ) );

        equals( 'domain.net', Jid.parseDomain('node@domain.net/Resource') );
        equals( 'domain.net', Jid.parseDomain('node@domain.net') );
        equals( 'domain', Jid.parseDomain('node@domain') );

		equals( 'Resource', Jid.parseResource('node@domain.net/Resource') );
        isNull( Jid.parseResource('node@domain.net') );
        isNull( Jid.parseResource('node@domain') );

		equals( 'node@domain.net', Jid.parseBare('node@domain.net/Resource') );
        equals( 'node@domain.net', Jid.parseBare('node@domain.net') );
        equals( 'node@domain', Jid.parseBare('node@domain') );
    }

    function test_from() {

        var jid : Jid = "node@domain.net/Resource";
        equals( "node", jid.node );
        equals( "domain.net", jid.domain );
        equals( "Resource", jid.resource );

        var jid : Jid = ["node","domain.net","Resource"];
        equals( "node", jid.node );
        equals( "domain.net", jid.domain );
        equals( "Resource", jid.resource );
    }

    function test_to() {

        var jid : Jid = "node@domain.net/Resource";

        var str : String = jid;
        equals( "node@domain.net/Resource", str );

        var arr : Array<String> = jid;
        equals( "node", arr[0] );
        equals( "domain.net", arr[1] );
        equals( "Resource", arr[2] );
    }

    function test_escape() {

        var str = 'joe smith"hugo&karl\\tom/che:ruth<elias>rotz@coma\\\\';
		equals( Jid.unescapeNode( Jid.escapeNode( str ) ), str );

        var str = '1\\202\\223\\264\\275\\2f6\\3a7\\3c8\\3e9\\4010\\5c';
		equals( "1 2\"3&4'5/6:7<8>9@10\\", Jid.unescapeNode( str ) );
		equals( str, Jid.escapeNode( Jid.unescapeNode( str ) ) );
	}

	function test_equals() {
		
		var a = new Jid( 'romeo', 'server.com', 'balcony' );
		var b = new Jid( 'julia', 'host.net', 'castle' );
		isFalse( a.equals(b) );
		isFalse( a == b );
		
		var a = new Jid( 'romeo', 'server.com', 'balcony' );
		var b = new Jid( 'romeo', 'server.com', 'balcony' );
		isTrue( a.equals(b) );
		isTrue( a == b );
	}

	function test_arrayaccess() {

		var a = new Jid( 'romeo', 'server.com', 'balcony' );
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

    function test_struct() {
        var jid : Jid = { node:'node', domain:'example.com', resource:'hxmpp' };
		equals('node', jid.node);
		equals('example.com', jid.domain);
		equals('hxmpp', jid.resource);
        jid = { domain: "example.com" };
		equals("example.com", jid.domain);
		isNull(jid.node);
		isNull(jid.resource);
    }
}
