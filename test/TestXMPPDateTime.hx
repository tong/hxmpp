
import xmpp.DateTime;

class TestXMPPDateTime extends TestCase {
	
	public function test() {
		
		// test time
		af( DateTime.isValidTime( "" ) );
		af( DateTime.isValidTime( "16" ) );
		af( DateTime.isValidTime( "16:00" ) );
		at( DateTime.isValidTime( "16:00:00" ) );
		af( DateTime.isValidTime( " 16:00:00" ) );
		af( DateTime.isValidTime( "16:00:00 " ) );
		af( DateTime.isValidTime( "16:00:00:" ) );
		at( DateTime.isValidTime( "16:00:00.123" ) );
		af( DateTime.isValidTime( "16:00:00:123" ) );
		at( DateTime.isValidTime( "16:00:00.123Z" ) );
		
		// test date
		af( DateTime.isValidDate( "" ) );
		af( DateTime.isValidDate( "1969" ) );
		af( DateTime.isValidDate( "1969-07" ) );
		at( DateTime.isValidDate( "1969-07-21" ) );
		af( DateTime.isValidDate( '1969-07-210' ) );
		
		// test full
		at( DateTime.isValidDate( '1969-07-21T02:56:15' ) );
		at( DateTime.isValidDate( '1969-07-21T02:56:15Z' ) );
		at( DateTime.isValidDate( '1969-07-21T02:56:15.123Z' ) );
		af( DateTime.isValidDate( '1969-07-21T02:56:15.1234Z' ) );
		at( DateTime.isValidDate( '1969-07-20T21:56:15-05:00' ) );
		af( DateTime.isValidDate( '1969-07-20T21:56:15Z05:00' ) );
		af( DateTime.isValidDate( '1969-07-20T21:56:15Z0' ) );
		
		// test create
		var now = "2009-05-06";
		eq( "2009-05-06", DateTime.utc( now ) );
		now = "2009-05-06";
		eq( "2009-05-06", DateTime.utc( now, 2 ) );
		now = "2009-05-06 16:16:27";
		eq( "2009-05-06T16:16:27Z", DateTime.utc( now ) );
		eq( "2009-05-06T16:16:27-02:00", DateTime.utc( now, 2 ) );
		
		/*
		var s = Date.now().toString();
	//	eq( s, DateTime.createDate( DateTime.utc( s ) ).toString() );
		var s = "2009-05-06T16:16:27";
	//	eq( "2009-05-06 16:16:27", DateTime.createDate( s ).toString() );
		var s = "2009-05-06";
		eq( null, DateTime.createDate( s ) );
		*/
	}
	
}
