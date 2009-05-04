
import jabber.MUCUtil;

class TestMUCUtil extends haxe.unit.TestCase {

	public function test() {
		
		assertFalse( MUCUtil.isValid( "" ) );
		assertFalse( MUCUtil.isValid( "haxe" ) );
		assertFalse( MUCUtil.isValid( "haxe@" ) );
		assertFalse( MUCUtil.isValid( "haxe/tong" ) );
		assertTrue( MUCUtil.isValid( "haxe@conference" ) );
		assertTrue( MUCUtil.isValid( "haxe@conference.jabber.org" ) );
		assertTrue( MUCUtil.isValid( "haxe@conference.jabber.org/tong" ) );
		
		var t = "haxe@conference.jabber.org/tong";
		assertEquals( "haxe", MUCUtil.getRoom( t ) );
		assertEquals( "conference.jabber.org", MUCUtil.getHost( t ) );
		assertEquals( "tong", MUCUtil.getOccupant( t ) );
		var parts = MUCUtil.getParts( t );
		assertEquals( 3, parts.length );
		assertEquals( "haxe", parts[0] );
		assertEquals( "conference.jabber.org", parts[1] );
		assertEquals( "tong", parts[2] );
		assertTrue( MUCUtil.isValidFull( t ) );
		
		t = "haxe@conference.jabber.org";
		var parts = MUCUtil.getParts( t );
		assertEquals( 2, parts.length );
		assertEquals( "haxe", parts[0] );
		assertEquals( "conference.jabber.org", parts[1] );
		assertEquals( null, MUCUtil.getOccupant( t ) );
		assertFalse( MUCUtil.isValidFull( t ) );
	}
	
}
