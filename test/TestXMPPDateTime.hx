
import xmpp.DateTime;

class TestXMPPDateTime extends haxe.unit.TestCase {
	
	public function test() {
		
		// test time
		assertFalse( DateTime.isValidTime( "" ) );
		assertFalse( DateTime.isValidTime( "16" ) );
		assertFalse( DateTime.isValidTime( "16:00" ) );
		assertTrue( DateTime.isValidTime( "16:00:00" ) );
		assertFalse( DateTime.isValidTime( " 16:00:00" ) );
		assertFalse( DateTime.isValidTime( "16:00:00 " ) );
		assertFalse( DateTime.isValidTime( "16:00:00:" ) );
		assertTrue( DateTime.isValidTime( "16:00:00.123" ) );
		assertFalse( DateTime.isValidTime( "16:00:00:123" ) );
		assertTrue( DateTime.isValidTime( "16:00:00.123Z" ) );
		
		// test date
		assertFalse( DateTime.isValidDate( "" ) );
		assertFalse( DateTime.isValidDate( "1969" ) );
		assertFalse( DateTime.isValidDate( "1969-07" ) );
		assertTrue( DateTime.isValidDate( "1969-07-21" ) );
		assertFalse( DateTime.isValidDate( '1969-07-210' ) );
		
		// test full
		assertTrue( DateTime.isValidDate( '1969-07-21T02:56:15' ) );
		assertTrue( DateTime.isValidDate( '1969-07-21T02:56:15Z' ) );
		assertTrue( DateTime.isValidDate( '1969-07-21T02:56:15.123Z' ) );
		assertFalse( DateTime.isValidDate( '1969-07-21T02:56:15.1234Z' ) );
		assertTrue( DateTime.isValidDate( '1969-07-20T21:56:15-05:00' ) );
		assertFalse( DateTime.isValidDate( '1969-07-20T21:56:15Z05:00' ) );
		assertFalse( DateTime.isValidDate( '1969-07-20T21:56:15Z0' ) );
		
		// test create
		var now = "2009-05-06";
		assertEquals( "2009-05-06", DateTime.utc( now ) );
		now = "2009-05-06";
		assertEquals( "2009-05-06", DateTime.utc( now, 2 ) );
		now = "2009-05-06 16:16:27";
		assertEquals( "2009-05-06T16:16:27Z", DateTime.utc( now ) );
		assertEquals( "2009-05-06T16:16:27-02:00", DateTime.utc( now, 2 ) );
		
		/*
		var s = Date.now().toString();
	//	assertEquals( s, DateTime.createDate( DateTime.utc( s ) ).toString() );
		var s = "2009-05-06T16:16:27";
	//	assertEquals( "2009-05-06 16:16:27", DateTime.createDate( s ).toString() );
		var s = "2009-05-06";
		assertEquals( null, DateTime.createDate( s ) );
		*/
	}
	
}
