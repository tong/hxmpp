
import xmpp.DateTime;

class TestXMPPDateTime extends haxe.unit.TestCase {
	
	public function test_validate() {

		// --- test date

		assertTrue( DateTime.isValidDate( "1969-07-21" ) );
		assertTrue( DateTime.isValidDate( "1-01-01" ) );

		assertFalse( DateTime.isValidDate( "sdf" ) );
		assertFalse( DateTime.isValidDate( "" ) );
		assertFalse( DateTime.isValidDate( "1969" ) );
		assertFalse( DateTime.isValidDate( "1969-07" ) );
		assertFalse( DateTime.isValidDate( '1969-07-210' ) );
		assertFalse( DateTime.isValidDate( '0-07-210' ) );
		//TODO assertFalse( DateTime.isValidDate( '0-00-00' ) );


		// --- test datetime

		assertTrue( DateTime.isValidDateTime( "1969-07-21" ) );
		assertTrue( DateTime.isValidDateTime( '1969-07-21T02:56:15' ) );
		assertTrue( DateTime.isValidDateTime( '1969-07-21T02:56:15Z' ) );
		assertTrue( DateTime.isValidDateTime( '1969-07-21T02:56:15.123' ) );
		assertTrue( DateTime.isValidDateTime( '1969-07-21T02:56:15.123Z' ) );
		assertTrue( DateTime.isValidDateTime( '1969-07-20T21:56:15-05' ) );
		assertTrue( DateTime.isValidDateTime( '1969-07-20T21:56:15-05:00' ) );

		assertFalse( DateTime.isValidDateTime( "sdf" ) );
		
		assertFalse( DateTime.isValidDateTime( '1969-07-20T21:56:15Z05:00' ) );
		assertFalse( DateTime.isValidDateTime( '1969-07-20T21:56:15Z05' ) );
		assertFalse( DateTime.isValidDateTime( '1969-07-20T21:56:15-05:0' ) );
		assertFalse( DateTime.isValidDateTime( '1969-07-20T21:56:15-0:05' ) );
		assertFalse( DateTime.isValidDateTime( '1969-07-20T21:56:15-00:005' ) );
		assertFalse( DateTime.isValidDateTime( '1969-07-20T21:56:15-000:05' ) );

		// --- test time

		assertTrue( DateTime.isValidTime( "16:00:00" ) );
		assertTrue( DateTime.isValidTime( "16:00:00.1" ) );
		assertTrue( DateTime.isValidTime( "16:00:00.12" ) );
		assertTrue( DateTime.isValidTime( "16:00:00.123" ) );
		
		assertFalse( DateTime.isValidTime( "sdf" ) );
		assertFalse( DateTime.isValidTime( "6:00:00" ) );
		assertFalse( DateTime.isValidTime( "a6:00:00" ) );
		assertFalse( DateTime.isValidTime( "16:0:00" ) );
		assertFalse( DateTime.isValidTime( "16:00:0" ) );
		assertFalse( DateTime.isValidTime( "16:00:00:123" ) );
		assertFalse( DateTime.isValidTime( "16" ) );
		assertFalse( DateTime.isValidTime( "16:00" ) );
		assertFalse( DateTime.isValidTime( " 16:00:00" ) );
		assertFalse( DateTime.isValidTime( "16:00:00 " ) );
	}

	public function test_create() {

		var now = Date.now();
		assertEquals( now.getFullYear(), DateTime.ofDate(now).year );
		assertEquals( now.getMonth(), DateTime.ofDate(now).month );
		assertEquals( now.getDay(), DateTime.ofDate(now).day );
		assertEquals( now.getHours(), DateTime.ofDate(now).hour );
		assertEquals( now.getMinutes(), DateTime.ofDate(now).min );
		assertEquals( now.getSeconds(), DateTime.ofDate(now).sec );
		assertEquals( null, DateTime.ofDate(now).ms );
		assertEquals( null, DateTime.ofDate(now).tz );
	}

	
	public function test_parse() {

		var parts = DateTime.getDateTimeParts( '1969-07-20' );
		assertEquals( 3, parts.length );
		assertEquals( 1969, parts[0] );
		assertEquals( 7, parts[1] );
		assertEquals( 20, parts[2] );

		parts = DateTime.getDateTimeParts( '1969-07-20T16:23:03' );
		assertEquals( 7, parts.length );
		assertEquals( 1969, parts[0] );
		assertEquals( 7, parts[1] );
		assertEquals( 20, parts[2] );
		assertEquals( 16, parts[3] );
		assertEquals( 23, parts[4] );
		assertEquals( 3, parts[5] );

		parts = DateTime.getDateTimeParts( '1969-07-20T16:23:03Z' );
		assertEquals( 7, parts.length );
		assertEquals( 1969, parts[0] );
		assertEquals( 7, parts[1] );
		assertEquals( 20, parts[2] );
		assertEquals( 16, parts[3] );
		assertEquals( 23, parts[4] );
		assertEquals( 3, parts[5] );

		parts = DateTime.getDateTimeParts( '1969-07-20T16:23:03-13:30' );
		assertEquals( 1969, parts[0] );
		assertEquals( 7, parts[1] );
		assertEquals( 20, parts[2] );
		assertEquals( 16, parts[3] );
		assertEquals( 23, parts[4] );
		assertEquals( 3, parts[5] );
		assertEquals( null, parts[6] );
		assertEquals( 13, parts[7] );
		assertEquals( 30, parts[8] );

		parts = DateTime.getDateTimeParts( '1969-07-20T16:23:03-13' );
		assertEquals( 1969, parts[0] );
		assertEquals( 7, parts[1] );
		assertEquals( 20, parts[2] );
		assertEquals( 16, parts[3] );
		assertEquals( 23, parts[4] );
		assertEquals( 3, parts[5] );
		assertEquals( null, parts[6] );
		assertEquals( 13, parts[7] );
		assertEquals( null, parts[8] );
	}
	
}
