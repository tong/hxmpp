
import jabber.JID;
import jabber.JIDUtil;


class TestJID extends haxe.unit.TestCase   {
	
	public function testJIDUtil() {
		
		var j1 = "nodemain.net/Resource";
		assertTrue( !jabber.JIDUtil.ereg.match( j1 ) );
		assertTrue( !JIDUtil.isValid( j1 ) );
		
		var j1 = "node@domain.net/Resource";
		assertTrue( jabber.JIDUtil.ereg.match( j1 ) );
		assertTrue( JIDUtil.isValid( j1 ) );
		assertEquals( "node", JIDUtil.parseNode( j1 ) );
		assertEquals( "domain.net", JIDUtil.parseDomain( j1 ) );
		assertTrue( JIDUtil.hasResource( j1 ) );
		assertEquals( "Resource", JIDUtil.parseResource( j1 ) );
		
		var j2 = "node@domain.net";
		assertTrue( jabber.JIDUtil.ereg.match( j2 ) );
		assertTrue( JIDUtil.isValid( j2 ) );
		assertEquals(  "node", JIDUtil.parseNode( j2 ) );
		assertEquals( "domain.net", JIDUtil.parseDomain( j2 ) );
		assertTrue( !JIDUtil.hasResource( j2 ) );
		assertEquals( null, JIDUtil.parseResource( j2 ) );
		
		var parts1 = JIDUtil.getParts( j1 );
		assertEquals( "node", parts1[0] );
		assertEquals( "domain.net", parts1[1] );
		assertEquals( "Resource", parts1[2] );
		
		var parts2 = JIDUtil.getParts( j2 );
		assertEquals( "node", parts2[0] );
		assertEquals( "domain.net", parts2[1] );
		
		#if JABBER_DEBUG
		var j = "node@domain.net/Resource";
		assertTrue( jabber.JIDUtil.ereg.match( j ) );
		assertTrue( JIDUtil.isValid( j ) );
		j = "node@domain.net";
		assertTrue( jabber.JIDUtil.ereg.match( j ) );
		assertTrue( JIDUtil.isValid( j ) );
		j = "node@domain";
		assertTrue( jabber.JIDUtil.ereg.match( j ) );
		assertTrue( JIDUtil.isValid( j ) );
		j = "node@domain/Resource";
		assertTrue( jabber.JIDUtil.ereg.match( j ) );
		assertTrue( JIDUtil.isValid( j ) );
		j = "node";
		assertTrue( !jabber.JIDUtil.ereg.match( j ) );
		assertTrue( !JIDUtil.isValid( j ) );
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
	
	public function testJIDEscaping() {
		var node = 'joe smith"hugo&karl\\tom/che:ruth<elias>rotz@coma\\\\';
		assertEquals( JIDUtil.unescapeNode( JIDUtil.escapeNode( node ) ), node );
	}
	
}
