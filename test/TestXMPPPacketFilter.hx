
import xmpp.Packet;
import xmpp.PacketType;
import xmpp.Message;
import xmpp.Presence;
import xmpp.IQ;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketAllFilter;
import xmpp.filter.PacketFromContainsFilter;
import xmpp.filter.PacketFromFilter;
import xmpp.filter.PacketIDFilter;
import xmpp.filter.PacketTypeFilter;
import xmpp.filter.IQFilter;


class TestXMPPPacketFilter {
	
	static function main() {
		
		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		var r = new haxe.unit.TestRunner();
		r.add( new TestFilters() );
		r.run();
	}
}


class TestFilters extends haxe.unit.TestCase {
	
	public function testMessageTypeFilter() {
		var f = new MessageFilter();
		assertTrue( !f.accept( new Presence() ) );
		assertTrue( !f.accept( new IQ() ) );
		assertTrue( f.accept( new Message() ) );
		assertTrue( !f.accept( new Message( chat ) ) );
		assertTrue( !f.accept( new Message( error ) ) );
		assertTrue( !f.accept( new Message( groupchat ) ) );
		assertTrue( !f.accept( new Message( headline ) ) );
		f = new MessageFilter( chat );
		assertTrue( f.accept( new Message( chat ) ) );
		assertTrue( !f.accept( new Message() ) );
		assertTrue( !f.accept( new Message( normal ) ) );
		assertTrue( !f.accept( new Message( groupchat ) ) );
		assertTrue( !f.accept( new Message( error ) ) );
		assertTrue( !f.accept( new Message( groupchat ) ) );
		assertTrue( !f.accept( new Message( headline ) ) );
	}
	
	public function testAcceptAllFilter() {
		assertTrue( new PacketAllFilter().accept( new Message() ) );
		assertTrue( new PacketAllFilter().accept( new Presence() ) );
		assertTrue( new PacketAllFilter().accept( new IQ() ) );
	}
	
	public function testFromContainsFilter() {
		var m = new Message();
		m.from = "sender@domain.net/resource";
		var fcf = new PacketFromContainsFilter( "sender" );
		assertTrue( fcf.accept( m ) );
		fcf = new PacketFromContainsFilter( "domain.net" );
		assertTrue( fcf.accept( m ) );
		fcf = new PacketFromContainsFilter( "resource" );
		assertTrue( fcf.accept( m ) );
		fcf = new PacketFromContainsFilter( "WRoNG" );
		assertTrue( !fcf.accept( m ) );
	}
	
	public function testFromFilter() {
		var m = new Message();
		m.from = "sender@domain.net";
		var ff = new PacketFromFilter( "sender@domain.net" );
		assertTrue( ff.accept( m ) );
		m.from = "changed@domain.net";
		ff = new PacketFromFilter( "changed@domain.net" );
		assertTrue( ff.accept( m ) );
	}
	
	public function testIDFilter() {
		var iq = new IQ( null, "12345" );
		var f = new PacketIDFilter( "12345" );
		assertTrue( f.accept( iq ) );
		iq.id = "54321";
		assertTrue( !f.accept( iq ) );
	}
	
	public function testTypeFilter() {
		var mf = new PacketTypeFilter( PacketType.message );
		assertTrue( mf.accept( new Message() ) );
		assertTrue( !mf.accept( new Presence() ) );
		assertTrue( !mf.accept( new IQ() ) );
		var pf = new PacketTypeFilter( PacketType.presence );
		assertTrue( pf.accept( new Presence() ) );
		assertTrue( !pf.accept( new Message() ) );
		assertTrue( !pf.accept( new IQ() ) );
		var iqf = new PacketTypeFilter( PacketType.iq );
		assertTrue( iqf.accept( new IQ() ) );
		assertTrue( !iqf.accept( new Presence() ) );
		assertTrue( !iqf.accept( new Message() ) );
	}
	
	
	/*TODO
	public function testNameFilter() {
		//TODO
		assertTrue( true );
	}
	
	public function testIQFilter() {
		
		var f = new IQFilter( null, null, IQType.get );
		assertTrue( f.accept( new IQ( IQType.get ) ) );
		assertTrue( !f.accept( new IQ( IQType.set ) ) );
		assertTrue( !f.accept( new IQ( IQType.error ) ) );
		assertTrue( !f.accept( new IQ( IQType.result ) ) );
		
		f = new IQFilter( xmpp.IQAuth.XMLNS );
		assertTrue( f.accept( new xmpp.IQAuth() ) );
		assertTrue( !f.accept( new xmpp.IQRoster() ) );
	
		f = new IQFilter( xmpp.IQAuth.XMLNS, "query" );
		assertTrue( f.accept( new xmpp.IQAuth() ) );
		assertTrue( !f.accept( new xmpp.IQRoster() ) );
		
		f = new IQFilter( xmpp.IQAuth.XMLNS, "query", IQType.set );
		assertTrue( !f.accept( new xmpp.IQAuth() ) );
		assertTrue( !f.accept( new xmpp.IQRoster() ) );
		var iq = new xmpp.IQAuth();
		iq.type = IQType.set;
		assertTrue( f.accept( iq ) );
		
		f = new IQFilter( null, "query" );
		assertTrue( f.accept( new xmpp.IQAuth() ) );
		assertTrue( f.accept( new xmpp.IQRoster() ) );
		assertTrue( f.accept( new xmpp.IQDiscoInfo() ) );
	}
	*/
}
