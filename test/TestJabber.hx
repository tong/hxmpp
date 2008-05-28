
import jabber.JID;
import jabber.util.JIDUtil;


class TestJabber {
	
	static function main() {
		
		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
			
		var r = new haxe.unit.TestRunner();
		r.add( new TestJID() );
		r.run();
	}
}



class TestJID extends haxe.unit.TestCase   {
	
	
	//public function new() { super(); }
	
	
	public function testJIDUtil() {
		
		var j1 = "node@domain.net/Resource";
		assertTrue( JIDUtil.isValid( j1 ) );
		assertEquals( "node", JIDUtil.parseNode( j1 ) );
		assertEquals( "domain.net", JIDUtil.parseDomain( j1 ) );
		assertTrue( JIDUtil.hasResource( j1 ) );
		assertEquals( "Resource", JIDUtil.parseResource( j1 ) );
		
		var j2 = "node@domain.net";
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
		assertEquals( null, parts2[2] );
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
		assertEquals( "node@domain.net", jid.barAdress );
		
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
		assertEquals( "node@domain.net", jid.barAdress );
		
		parts = JIDUtil.getParts( jid_str );
		assertEquals( "node", parts[0] );
		assertEquals( "domain.net", parts[1] );
		assertEquals( null, parts[2] );
	}
	
	
	public function testJIDEscaping() {
		var node = 'joe smith"hugo&karl\\tom/che:ruth<elias>rotz@coma\\\\';
		assertEquals( JIDUtil.unescapeNode( JIDUtil.escapeNode( node ) ), node );
	}
}
