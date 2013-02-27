
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
		assertEquals( "tong", MUCUtil.getNick( t ) );
		var parts = MUCUtil.getParts( t );
		assertEquals( 3, parts.length );
		assertEquals( "haxe", parts[0] );
		assertEquals( "conference.jabber.org", parts[1] );
		assertEquals( "tong", parts[2] );
		assertTrue( MUCUtil.isValid( t, true ) );
		assertTrue( MUCUtil.isValid( t ) );
		
		t = "haxe@conference.jabber.org";
		var parts = MUCUtil.getParts( t );
		assertEquals( 2, parts.length );
		assertEquals( "haxe", parts[0] );
		assertEquals( "conference.jabber.org", parts[1] );
		assertEquals( null, MUCUtil.getNick( t ) );
		assertFalse( MUCUtil.isValid( t, true ) );
		assertTrue( MUCUtil.isValid( t ) );
		
		assertTrue( MUCUtil.EREG.match( t ) );
		assertEquals( t, MUCUtil.EREG.matched( 0 ) );
		assertEquals( "haxe", MUCUtil.EREG.matched( 1 ) );
		assertEquals( "conference.jabber.org", MUCUtil.EREG.matched( 2 ) );
		assertEquals( null, MUCUtil.EREG.matched( 3 ) );
		
		t = "haxe@conference.jabber.org/nick";
		assertTrue( MUCUtil.EREG.match( t ) );
		assertEquals( t, MUCUtil.EREG.matched( 0 ) );
		assertEquals( "haxe", MUCUtil.EREG.matched( 1 ) );
		assertEquals( "conference.jabber.org", MUCUtil.EREG.matched( 2 ) );
		assertEquals( "/nick", MUCUtil.EREG.matched( 3 ) );
		assertEquals( "nick", MUCUtil.EREG.matched( 4 ) );
	}
	
}
