
import jabber.JID;
import jabber.JIDUtil;

class TestJID extends haxe.unit.TestCase {
	
	public function testValidation() {
		
		assertFalse( JIDUtil.isValid( "nodedomain.net" ) );
		assertTrue( JIDUtil.isValid( "node@domain" ) );
		assertTrue( JIDUtil.isValid( "node@domain/Resource" ) );
		assertTrue( JIDUtil.isValid( "node@domain.net/Resource" ) );
		assertTrue( JIDUtil.isValid( "node@domain.net" ) );
		assertTrue( JIDUtil.isValid( "node@sub.domain.com" ) );
		assertTrue( JIDUtil.isValid( "node@sub.domain.com/Resource" ) );
		
		#if JABBER_DEBUG
		assertFalse( JIDUtil.isValid( "node@domain" ) );
		assertTrue( JIDUtil.isValid( "node@domain" ) );
		assertTrue( JIDUtil.isValid( "node@domain/Resource" ) );
		assertTrue( JIDUtil.isValid( "node@sub.domain.com/Resource" ) );
		#end
	}
		
	public function testParse() {
		
		var t = "node@domain.net/Resource";
		assertEquals( "node", JIDUtil.parseNode( t ) );
		assertEquals( "domain.net", JIDUtil.parseDomain( t ) );
		assertEquals( "Resource", JIDUtil.parseResource( t ) );
		var parts = JIDUtil.getParts( t );
		assertEquals( "node", parts[0] );
		assertEquals( "domain.net", parts[1] );
		assertEquals( "Resource", parts[2] );
		
		var t = "node@sub.domain.net/Resource";
		assertEquals( "node", JIDUtil.parseNode( t ) );
		assertEquals( "sub.domain.net", JIDUtil.parseDomain( t ) );
		assertEquals( "Resource", JIDUtil.parseResource( t ) );
		var parts = JIDUtil.getParts( t );
		assertEquals( "node", parts[0] );
		assertEquals( "sub.domain.net", parts[1] );
		assertEquals( "Resource", parts[2] );
		
		#if JABBER_DEBUG
		var t = "node@domain/Resource";
		assertEquals( "node", JIDUtil.parseNode( t ) );
		assertEquals( "domain", JIDUtil.parseDomain( t ) );
		assertEquals( "Resource", JIDUtil.parseResource( t ) );
		var parts = JIDUtil.getParts( t );
		assertEquals( "node", parts[0] );
		assertEquals( "domain", parts[1] );
		assertEquals( "Resource", parts[2] );
		
		#end
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
		
		var parts = JIDUtil.getParts( jid_str );
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
		
		parts = JIDUtil.getParts( jid_str );
		assertEquals( "node", parts[0] );
		assertEquals( "domain.net", parts[1] );
	}
	
	public function testEscaping() {
		var node = 'joe smith"hugo&karl\\tom/che:ruth<elias>rotz@coma\\\\';
		assertEquals( JIDUtil.unescapeNode( JIDUtil.escapeNode( node ) ), node );
	}
	
}
