
import jabber.JID;
import jabber.JIDUtil;

class TestJID extends TestCase {
	
	public function testValidation() {
		
		#if JABBER_DEBUG
		af( JIDUtil.isValid( "aaa" ) );
		af( JIDUtil.isValid( "nodedomain.net" ) );
		af( JIDUtil.isValid( "nodedomain.at" ) );
		at( JIDUtil.isValid( "node@domain" ) );
		at( JIDUtil.isValid( "node@domain/Resource" ) );
		at( JIDUtil.isValid( "node@domain.net/Resource" ) );
		at( JIDUtil.isValid( "node@domain.net" ) );
		at( JIDUtil.isValid( "node@sub.domain.com" ) );
		at( JIDUtil.isValid( "node@sub.domain.com/Resource" ) );
		
		#else
		af( JIDUtil.isValid( "aaa" ) );
		af( JIDUtil.isValid( "nodedomain.net" ) );
		af( JIDUtil.isValid( "node@domain" ) );
		af( JIDUtil.isValid( "node@domain/Resource" ) );
		at( JIDUtil.isValid( "node@domain.net/Resource" ) );
		at( JIDUtil.isValid( "node@domain.net" ) );
		at( JIDUtil.isValid( "node@sub.domain.com" ) );
		at( JIDUtil.isValid( "node@sub.domain.com/Resource" ) );
		at( JIDUtil.isValid( "node@dd.net" ) );
		
		#end
	}
		
	public function testParse() {
		
		var t = "node@domain.net/Resource";
		eq( "node", JIDUtil.node( t ) );
		eq( "domain.net", JIDUtil.domain( t ) );
		eq( "Resource", JIDUtil.resource( t ) );
		var parts = JIDUtil.parts( t );
		eq( "node", parts[0] );
		eq( "domain.net", parts[1] );
		eq( "Resource", parts[2] );
		
		var t = "node@sub.domain.net/Resource";
		eq( "node", JIDUtil.node( t ) );
		eq( "sub.domain.net", JIDUtil.domain( t ) );
		eq( "Resource", JIDUtil.resource( t ) );
		var parts = JIDUtil.parts( t );
		eq( "node", parts[0] );
		eq( "sub.domain.net", parts[1] );
		eq( "Resource", parts[2] );
		
		#if JABBER_DEBUG
		var t = "node@domain/Resource";
		eq( "node", JIDUtil.node( t ) );
		eq( "domain", JIDUtil.domain( t ) );
		eq( "Resource", JIDUtil.resource( t ) );
		
		var parts = JIDUtil.getParts( t );
		eq( "node", parts[0] );
		eq( "domain", parts[1] );
		eq( "Resource", parts[2] );
		
		at( JIDUtil.EREG.match( t ) );
		eq( t, JIDUtil.EREG.matched( 0 ) );
		eq( "node", JIDUtil.EREG.matched( 1 ) );
		eq( "domain", JIDUtil.EREG.matched( 2 ) );
		eq( "Resource", JIDUtil.EREG.matched( 5 ) );
		
		#else
		
		at( JIDUtil.EREG.match( t ) );
		eq( t, JIDUtil.EREG.matched( 0 ) );
		eq( "node", JIDUtil.EREG.matched( 1 ) );
		eq( "sub.domain.net", JIDUtil.EREG.matched( 2 ) );
		eq( "Resource", JIDUtil.EREG.matched( 4 ) );
		
		#end
	}
	
	public function testJID() {
		
		var jid_str = "node@domain.net/Resource";
		var jid = new JID( jid_str );
		eq( jid_str, jid.toString() );
		eq( jid_str, jid.toString() );
		eq( "node", jid.node );
		eq( "domain.net", jid.domain );
		at( JIDUtil.hasResource( jid_str ) );
		eq( "Resource", jid.resource );
		eq( "node@domain.net", jid.bare );
		var parts = JIDUtil.parts( jid_str );
		eq( "node", parts[0] );
		eq( "domain.net", parts[1] );
		eq( "Resource", parts[2] );
		
		jid_str = "node@domain.net";
		jid = new JID( jid_str );
		eq( jid_str, jid.toString() );
		eq( "node", jid.node );
		eq( "domain.net", jid.domain );
		at( !JIDUtil.hasResource( jid_str ) );
		eq( null, jid.resource );
		eq( "node@domain.net", jid.bare );
		parts = JIDUtil.parts( jid_str );
		eq( "node", parts[0] );
		eq( "domain.net", parts[1] );
	}
	
	public function testEscaping() {
		var t = 'joe smith"hugo&karl\\tom/che:ruth<elias>rotz@coma\\\\';
		eq( JIDUtil.unescapeNode( JIDUtil.escapeNode( t ) ), t );
		var t = '1\\202\\223\\264\\275\\2f6\\3a7\\3c8\\3e9\\4010\\5c';
		eq( "1 2\"3&4'5/6:7<8>9@10\\", JIDUtil.unescapeNode( t ) );
		eq( JIDUtil.escapeNode( JIDUtil.unescapeNode( t ) ), t );
	}
	
}
