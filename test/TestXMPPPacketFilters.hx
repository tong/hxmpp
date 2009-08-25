
import xmpp.Packet;
import xmpp.PacketType;
import xmpp.Message;
import xmpp.MessageType;
import xmpp.Presence;
import xmpp.PlainPacket;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.filter.FilterReverse;
import xmpp.filter.FilterGroup;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketAllFilter;
import xmpp.filter.PacketFieldFilter;
import xmpp.filter.PacketFromContainsFilter;
import xmpp.filter.PacketToContainsFilter;
import xmpp.filter.PacketFromFilter;
import xmpp.filter.PacketIDFilter;
import xmpp.filter.PacketNameFilter;
import xmpp.filter.PacketTypeFilter;
import xmpp.filter.IQFilter;


class TestXMPPPacketFilters extends haxe.unit.TestCase {
	
	public function testMessageTypeFilter() {
		
		var f = new MessageFilter();
		assertTrue( !f.accept( new Presence() ) );
		assertTrue( !f.accept( new IQ() ) );
		assertTrue( f.accept( new Message() ) );
		assertTrue( f.accept( new Message( chat ) ) );
		assertTrue( f.accept( new Message( error ) ) );
		assertTrue( f.accept( new Message( groupchat ) ) );
		assertTrue( f.accept( new Message( headline ) ) );
		
		f = new MessageFilter( chat );
		assertTrue( f.accept( new Message() ) );
		assertTrue( f.accept( new Message( chat ) ) );
		assertTrue( !f.accept( new Message( normal ) ) );
		assertTrue( !f.accept( new Message( groupchat ) ) );
		assertTrue( !f.accept( new Message( error ) ) );
		assertTrue( !f.accept( new Message( groupchat ) ) );
		assertTrue( !f.accept( new Message( headline ) ) );
		
		/*
		var m = xmpp.Message.parse( Xml.parse( '<message id="aadba" from="disktree@conference.disktree/tong" to="hxmpp@disktree/spekchat" type="groupchat"> <body>yg</body> <nick xmlns="http://jabber.org/protocol/nick">account</nick> <x from="account@disktree/desktop" xmlns="jabber:x:delay" stamp="20081110T15:07:05"/></message>' ).firstElement() );
		f = new MessageFilter( groupchat );
		assertTrue( f.accept( m ) );
		
		var f = new PacketFromContainsFilter( "disktree@conference.disktree" );
		assertTrue( f.accept( m ) );
*/
	}
	
	public function testAcceptAllFilter() {
		assertTrue( new PacketAllFilter().accept( new Message() ) );
		assertTrue( new PacketAllFilter().accept( new Presence() ) );
		assertTrue( new PacketAllFilter().accept( new IQ() ) );
	}
	
	public function testFromContainsFilter() {
		var m = new Message();
		m.from = "sender@domain.net/resource";
		var f = new PacketFromContainsFilter( "sender" );
		assertTrue( f.accept( m ) );
		f = new PacketFromContainsFilter( "domain.net" );
		assertTrue( f.accept( m ) );
		f = new PacketFromContainsFilter( "resource" );
		assertTrue( f.accept( m ) );
		f = new PacketFromContainsFilter( "WRoNG" );
		assertFalse( f.accept( m ) );
	}
	
	public function testToContainsFilter() {
		var m = new Message( "sender@domain.net/resource", "mybody", "mysubject" );
		var f = new PacketToContainsFilter( "sender" );
		assertTrue( f.accept( m ) );
		f = new PacketToContainsFilter( "senderx" );
		assertFalse( f.accept( m ) );
		f = new PacketToContainsFilter( "domain.net" );
		assertTrue( f.accept( m ) );
		f = new PacketToContainsFilter( "resource" );
		assertTrue( f.accept( m ) );
		f = new PacketToContainsFilter( "WRoNG" );
		assertFalse( f.accept( m ) );
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
	
	public function testIQFilter() {
		
		var f = new IQFilter( null, null, IQType.get );
		assertTrue( f.accept( new IQ( IQType.get ) ) );
		assertTrue( !f.accept( new IQ( IQType.set ) ) );
		assertTrue( !f.accept( new IQ( IQType.error ) ) );
		assertTrue( !f.accept( new IQ( IQType.result ) ) );
		
		var iq_auth = new IQ();
		iq_auth.x = new xmpp.Auth();
		var iq_roster = new IQ();
		iq_roster.x = new xmpp.Roster();
		
		f = new IQFilter( xmpp.Auth.XMLNS );
		assertTrue( f.accept( iq_auth ) );
		assertTrue( !f.accept( iq_roster ) );
	
		f = new IQFilter( xmpp.Auth.XMLNS, "query" );
		assertTrue( f.accept( iq_auth ) );
		assertTrue( !f.accept( iq_roster ) );
		
		f = new IQFilter( xmpp.Auth.XMLNS, "query", IQType.set );
		assertTrue( !f.accept( iq_auth ) );
		assertTrue( !f.accept( iq_roster ) );
		iq_auth.type = IQType.set;
		assertTrue( f.accept( iq_auth ) );
		
		f = new IQFilter( null, "query" );
		assertTrue( f.accept( iq_auth ) );
		assertTrue( f.accept( iq_roster ) );
	}
	
	public function testNameFilter() {
		
		var f = new PacketNameFilter( ~/message/ );
		assertTrue( f.accept( new Message() ) );
		assertTrue( !f.accept( new Presence() ) );
		assertTrue( !f.accept( new IQ() ) );
		
		f = new PacketNameFilter( ~/presence/ );
		assertTrue( !f.accept( new Message() ) );
		assertTrue( f.accept( new Presence() ) );
		assertTrue( !f.accept( new IQ() ) );
		
		// TODO
		/*
		f = new PacketNameFilter( ~// );
		assertTrue( f.accept( new Message() ) );
		assertTrue( f.accept( new Presence() ) );
		assertTrue( f.accept( new IQ() ) );
		var x = Xml.parse( '<custom id="123"></custom>' ).firstElement();
		trace(x.nodeName);
		assertTrue( !f.accept( new PlainPacket( x ) ) );
		*/
		
	}
	
	public function testFieldFilter() {
		var m = new Message();
		m.to = "node@disktree.net";
		m.from = "me@disktree.net";
		var f = new PacketFieldFilter( "to", "node@disktree.net" );
		assertTrue( f.accept( m ) );
		f = new PacketFieldFilter( "to" );
		assertTrue( f.accept( m ) );
		f = new PacketFieldFilter( "toooooooo" );
		assertTrue( !f.accept( m ) );
	}
	
	public function testFilterReverse() {
		var f = new PacketFromFilter("node@domain.net");
		var r = new FilterReverse( f );
		var m = new Message();
		m.from = "node@domain.net";
		assertTrue( f.accept( m ) );
		assertFalse( r.accept( m ) );
		m.from = "any@domain.net";
		assertFalse( f.accept( m ) );
		assertTrue( r.accept( m ) );
	}
	
	public function testFilterGroup() {
		var m = new Message();
		m.from = "node@domain.net";
		var f1 = new PacketTypeFilter( PacketType.message );
		var f2 = new PacketTypeFilter( PacketType.presence );
		var group = new FilterGroup( [cast f1, cast f2] );
		assertTrue( group.accept( m ) );
		f2 = new PacketTypeFilter( PacketType.presence );
		group = new FilterGroup( [cast f2] );
		assertFalse( group.accept( m ) );
	}
	
}
