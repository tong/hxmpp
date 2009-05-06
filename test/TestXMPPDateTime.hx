

class TestXMPPDateTime extends haxe.unit.TestCase {
	
	public function test() {
		
		// test time
		assertFalse( xmpp.DateTime.isValidTime( "16" ) );
		assertFalse( xmpp.DateTime.isValidTime( "16:00" ) );
		assertTrue( xmpp.DateTime.isValidTime( "16:00:00" ) );
		assertFalse( xmpp.DateTime.isValidTime( "16:00:00:" ) );
		assertTrue( xmpp.DateTime.isValidTime( "16:00:00.123" ) );
		assertFalse( xmpp.DateTime.isValidTime( "16:00:00:123" ) );
		assertTrue( xmpp.DateTime.isValidTime( "16:00:00.123Z" ) );
		
		// test date
		assertFalse( xmpp.DateTime.isValidTime( "" ) );
		assertFalse( xmpp.DateTime.isValidTime( "1969" ) );
		assertFalse( xmpp.DateTime.isValidTime( "1969-07-21T02" ) );
		assertFalse( xmpp.DateTime.isValidDate( '1969-07-2102:56:15Z' ) );
		assertTrue( xmpp.DateTime.isValidDate( '1776-07-04' ) );
		assertFalse( xmpp.DateTime.isValidDate( '1776-07-040' ) );
		assertTrue( xmpp.DateTime.isValidDate( '1969-07-21T02:56:15Z' ) );
		assertTrue( xmpp.DateTime.isValidDate( '1969-07-21T02:56:15.123Z' ) );
		assertTrue( xmpp.DateTime.isValidDate( '1969-07-20T21:56:15-05:00' ) );
		
		// test formatting
		var now = "2009-05-06";
		assertEquals( "2009-05-06", xmpp.DateTime.format( now ) );
		now = "2009-05-06";
		assertEquals( "2009-05-06", xmpp.DateTime.format( now, 2 ) );
		now = "2009-05-06 16:16:27";
		assertEquals( "2009-05-06T16:16:27Z", xmpp.DateTime.format( now ) );
		assertEquals( "2009-05-06T16:16:27-02:00", xmpp.DateTime.format( now, 2 ) );
	}
	
}
