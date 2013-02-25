
import jabber.MUCUtil;

class TestMUCUtil extends TestCase {

	public function test() {
		
		af( MUCUtil.isValid( "" ) );
		af( MUCUtil.isValid( "haxe" ) );
		af( MUCUtil.isValid( "haxe@" ) );
		af( MUCUtil.isValid( "haxe/tong" ) );
		at( MUCUtil.isValid( "haxe@conference" ) );
		at( MUCUtil.isValid( "haxe@conference.jabber.org" ) );
		at( MUCUtil.isValid( "haxe@conference.jabber.org/tong" ) );
		
		var t = "haxe@conference.jabber.org/tong";
		eq( "haxe", MUCUtil.getRoom( t ) );
		eq( "conference.jabber.org", MUCUtil.getHost( t ) );
		eq( "tong", MUCUtil.getNick( t ) );
		var parts = MUCUtil.getParts( t );
		eq( 3, parts.length );
		eq( "haxe", parts[0] );
		eq( "conference.jabber.org", parts[1] );
		eq( "tong", parts[2] );
		at( MUCUtil.isValid( t, true ) );
		at( MUCUtil.isValid( t ) );
		
		t = "haxe@conference.jabber.org";
		var parts = MUCUtil.getParts( t );
		eq( 2, parts.length );
		eq( "haxe", parts[0] );
		eq( "conference.jabber.org", parts[1] );
		eq( null, MUCUtil.getNick( t ) );
		af( MUCUtil.isValid( t, true ) );
		at( MUCUtil.isValid( t ) );
		
		at( MUCUtil.EREG.match( t ) );
		eq( t, MUCUtil.EREG.matched( 0 ) );
		eq( "haxe", MUCUtil.EREG.matched( 1 ) );
		eq( "conference.jabber.org", MUCUtil.EREG.matched( 2 ) );
		eq( null, MUCUtil.EREG.matched( 3 ) );
		
		t = "haxe@conference.jabber.org/nick";
		at( MUCUtil.EREG.match( t ) );
		eq( t, MUCUtil.EREG.matched( 0 ) );
		eq( "haxe", MUCUtil.EREG.matched( 1 ) );
		eq( "conference.jabber.org", MUCUtil.EREG.matched( 2 ) );
		eq( "/nick", MUCUtil.EREG.matched( 3 ) );
		eq( "nick", MUCUtil.EREG.matched( 4 ) );
	}
	
}
