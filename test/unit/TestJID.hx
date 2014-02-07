
import jabber.JID;
import jabber.JIDUtil;

class TestJID extends haxe.unit.TestCase {
	
	public function testValidation() {
		#if jabber_debug
		assertFalse( JIDUtil.isValid( "aaa" ) );
		assertFalse( JIDUtil.isValid( "nodedomain.net" ) );
		assertFalse( JIDUtil.isValid( "nodedomain.at" ) );
		assertTrue( JIDUtil.isValid( "node@domain" ) );
		assertTrue( JIDUtil.isValid( "node@domain/Resource" ) );
		assertTrue( JIDUtil.isValid( "node@domain.net/Resource" ) );
		assertTrue( JIDUtil.isValid( "node@domain.net" ) );
		assertTrue( JIDUtil.isValid( "node@sub.domain.com" ) );
		assertTrue( JIDUtil.isValid( "node@sub.domain.com/Resource" ) );
		#else
		assertFalse( JIDUtil.isValid( "aaa" ) );
		assertFalse( JIDUtil.isValid( "nodedomain.net" ) );
		assertFalse( JIDUtil.isValid( "node@domain" ) );
		assertFalse( JIDUtil.isValid( "node@domain/Resource" ) );
		assertTrue( JIDUtil.isValid( "node@domain.net/Resource" ) );
		assertTrue( JIDUtil.isValid( "node@domain.net" ) );
		assertTrue( JIDUtil.isValid( "node@sub.domain.com" ) );
		assertTrue( JIDUtil.isValid( "node@sub.domain.com/Resource" ) );
		assertTrue( JIDUtil.isValid( "node@dd.net" ) );
		#end
	}
		
	public function testParse() {
		
		var t = "node@domain.net/Resource";
		assertEquals( "node", JIDUtil.node( t ) );
		assertEquals( "domain.net", JIDUtil.domain( t ) );
		assertEquals( "Resource", JIDUtil.resource( t ) );
		var parts = JIDUtil.parts( t );
		assertEquals( "node", parts[0] );
		assertEquals( "domain.net", parts[1] );
		assertEquals( "Resource", parts[2] );
		
		var t = "node@sub.domain.net/Resource";
		
		assertEquals( "node", JIDUtil.node( t ) );
		assertEquals( "sub.domain.net", JIDUtil.domain( t ) );
		assertEquals( "Resource", JIDUtil.resource( t ) );
		
		var parts = JIDUtil.parts( t );
		assertEquals( "node", parts[0] );
		assertEquals( "sub.domain.net", parts[1] );
		assertEquals( "Resource", parts[2] );
		
		assertTrue( JIDUtil.EREG.match( t ) );
		assertEquals( t, JIDUtil.EREG.matched( 0 ) );
		assertEquals( "node", JIDUtil.EREG.matched( 1 ) );
		assertEquals( "sub.domain.net", JIDUtil.EREG.matched( 2 ) );
		assertEquals( "Resource", JIDUtil.EREG.matched( 4 ) );

		/*
		#if jabber_debug
		
		var t = "node@domain/Resource";
		assertEquals( "node", JIDUtil.node( t ) );
		assertEquals( "domain", JIDUtil.domain( t ) );
		assertEquals( "Resource", JIDUtil.resource( t ) );
		
		var parts = JIDUtil.parts( t );
		assertEquals( "node", parts[0] );
		assertEquals( "domain", parts[1] );
		assertEquals( "Resource", parts[2] );
		
		assertTrue( JIDUtil.EREG.match( t ) );
		assertEquals( t, JIDUtil.EREG.matched( 0 ) );
		assertEquals( "node", JIDUtil.EREG.matched( 1 ) );
		assertEquals( "domain", JIDUtil.EREG.matched( 2 ) );
		assertEquals( "Resource", JIDUtil.EREG.matched( 5 ) );

		#else
		
		assertTrue( JIDUtil.EREG.match( t ) );
		assertEquals( t, JIDUtil.EREG.matched( 0 ) );
		assertEquals( "node", JIDUtil.EREG.matched( 1 ) );
		assertEquals( "sub.domain.net", JIDUtil.EREG.matched( 2 ) );
		assertEquals( "Resource", JIDUtil.EREG.matched( 4 ) );
		
		#end
		*/
	}
	
	public function testJID() {
		
		var jid_str = "node@domain.net/Resource";
		var jid = new JID( jid_str );
		assertEquals( jid_str, jid.toString() );
		assertEquals( jid_str, jid.toString() );
		assertEquals( "node", jid.node );
		assertEquals( "domain.net", jid.domain );
		assertTrue( JIDUtil.hasResource( jid_str ) );
		assertEquals( "Resource", jid.resource );
		assertEquals( "node@domain.net", jid.bare );
		var parts = JIDUtil.parts( jid_str );
		assertEquals( "node", parts[0] );
		assertEquals( "domain.net", parts[1] );
		assertEquals( "Resource", parts[2] );
		
		jid_str = "node@domain.net";
		jid = new JID( jid_str );
		assertEquals( jid_str, jid.toString() );
		assertEquals( "node", jid.node );
		assertEquals( "domain.net", jid.domain );
		assertTrue( !JIDUtil.hasResource( jid_str ) );
		assertEquals( null, jid.resource );
		assertEquals( "node@domain.net", jid.bare );
		parts = JIDUtil.parts( jid_str );
		assertEquals( "node", parts[0] );
		assertEquals( "domain.net", parts[1] );
	}
	
	public function testEscaping() {
		var t = 'joe smith"hugo&karl\\tom/che:ruth<elias>rotz@coma\\\\';
		assertEquals( JIDUtil.unescapeNode( JIDUtil.escapeNode( t ) ), t );
		var t = '1\\202\\223\\264\\275\\2f6\\3a7\\3c8\\3e9\\4010\\5c';
		assertEquals( "1 2\"3&4'5/6:7<8>9@10\\", JIDUtil.unescapeNode( t ) );
		assertEquals( JIDUtil.escapeNode( JIDUtil.unescapeNode( t ) ), t );
	}
	
}
