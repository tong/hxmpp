
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

class TestXMPPPacketFilters extends TestCase {
	
	public function testMessageTypeFilter() {
		
		var f = new MessageFilter();
		af( f.accept( new Presence() ) );
		af( f.accept( new IQ() ) );
		at( f.accept( new Message() ) );
		at( f.accept( new Message( chat ) ) );
		at( f.accept( new Message( error ) ) );
		at( f.accept( new Message( groupchat ) ) );
		at( f.accept( new Message( headline ) ) );
		
		f = new MessageFilter( chat );
		at( f.accept( new Message() ) );
		at( f.accept( new Message( chat ) ) );
		af( f.accept( new Message( normal ) ) );
		af( f.accept( new Message( groupchat ) ) );
		af( f.accept( new Message( error ) ) );
		af( f.accept( new Message( groupchat ) ) );
		af( f.accept( new Message( headline ) ) );
		
		/*
		var m = xmpp.Message.parse( Xml.parse( '<message id="aadba" from="disktree@conference.disktree/tong" to="hxmpp@disktree/spekchat" type="groupchat"> <body>yg</body> <nick xmlns="http://jabber.org/protocol/nick">account</nick> <x from="account@disktree/desktop" xmlns="jabber:x:delay" stamp="20081110T15:07:05"/></message>' ).firstElement() );
		f = new MessageFilter( groupchat );
		at( f.accept( m ) );
		
		var f = new PacketFromContainsFilter( "disktree@conference.disktree" );
		at( f.accept( m ) );
*/
	}
	
	public function testAcceptAllFilter() {
		at( new PacketAllFilter().accept( new Message() ) );
		at( new PacketAllFilter().accept( new Presence() ) );
		at( new PacketAllFilter().accept( new IQ() ) );
		at( new PacketAllFilter().accept( new xmpp.PlainPacket( Xml.parse( "<custom>123</custom>" ) ) ) );
	}
	
	public function testFromContainsFilter() {
		var m = new Message();
		m.from = "sender@domain.net/resource";
		var f = new PacketFromContainsFilter( "sender" );
		at( f.accept( m ) );
		f = new PacketFromContainsFilter( "domain.net" );
		at( f.accept( m ) );
		f = new PacketFromContainsFilter( "resource" );
		at( f.accept( m ) );
		f = new PacketFromContainsFilter( "WRoNG" );
		af( f.accept( m ) );
	}
	
	public function testToContainsFilter() {
		var m = new Message( "sender@domain.net/resource", "mybody", "mysubject" );
		var f = new PacketToContainsFilter( "sender" );
		at( f.accept( m ) );
		f = new PacketToContainsFilter( "senderx" );
		af( f.accept( m ) );
		f = new PacketToContainsFilter( "domain.net" );
		at( f.accept( m ) );
		f = new PacketToContainsFilter( "resource" );
		at( f.accept( m ) );
		f = new PacketToContainsFilter( "WRoNG" );
		af( f.accept( m ) );
	}
	
	public function testFromFilter() {
		var m = new Message();
		m.from = "sender@domain.net";
		var ff = new PacketFromFilter( "sender@domain.net" );
		at( ff.accept( m ) );
		m.from = "changed@domain.net";
		ff = new PacketFromFilter( "changed@domain.net" );
		at( ff.accept( m ) );
	}
	
	public function testIDFilter() {
		var iq = new IQ( null, "12345" );
		var f = new PacketIDFilter( "12345" );
		at( f.accept( iq ) );
		iq.id = "54321";
		af( f.accept( iq ) );
		iq.id = null;
		af( f.accept( iq ) );
	}
	
	public function testTypeFilter() {
		var f = new PacketTypeFilter( PacketType.message );
		at( f.accept( new Message() ) );
		af( f.accept( new Presence() ) );
		af( f.accept( new IQ() ) );
		f = new PacketTypeFilter( PacketType.presence );
		at( f.accept( new Presence() ) );
		af( f.accept( new Message() ) );
		af( f.accept( new IQ() ) );
		f = new PacketTypeFilter( PacketType.iq );
		at( f.accept( new IQ() ) );
		af( f.accept( new Presence() ) );
		af( f.accept( new Message() ) );
	}
	
	public function testIQFilter() {
		
		var f = new IQFilter( null, IQType.get );
		at( f.accept( new IQ( IQType.get ) ) );
		at( !f.accept( new IQ( IQType.set ) ) );
		at( !f.accept( new IQ( IQType.error ) ) );
		at( !f.accept( new IQ( IQType.result ) ) );
		
		var iq_auth = new IQ();
		iq_auth.x = new xmpp.Auth();
		var iq_roster = new IQ();
		iq_roster.x = new xmpp.Roster();
		
		f = new IQFilter( xmpp.Auth.XMLNS );
		at( f.accept( iq_auth ) );
		at( !f.accept( iq_roster ) );
	
		f = new IQFilter( xmpp.Auth.XMLNS, "query" );
		at( f.accept( iq_auth ) );
		at( !f.accept( iq_roster ) );
		
		f = new IQFilter( xmpp.Auth.XMLNS, IQType.set, "query" );
		at( !f.accept( iq_auth ) );
		at( !f.accept( iq_roster ) );
		iq_auth.type = IQType.set;
		at( f.accept( iq_auth ) );
		
		f = new IQFilter( null, "query" );
		at( f.accept( iq_auth ) );
		at( f.accept( iq_roster ) );
	}
	
	public function testNameFilter() {
		
		var f = new PacketNameFilter( ~/message/ );
		at( f.accept( new Message() ) );
		at( !f.accept( new Presence() ) );
		at( !f.accept( new IQ() ) );
		
		f = new PacketNameFilter( ~/presence/ );
		at( !f.accept( new Message() ) );
		at( f.accept( new Presence() ) );
		at( !f.accept( new IQ() ) );
		
		// TODO
		/*
		f = new PacketNameFilter( ~// );
		at( f.accept( new Message() ) );
		at( f.accept( new Presence() ) );
		at( f.accept( new IQ() ) );
		var x = Xml.parse( '<custom id="123"></custom>' ).firstElement();
		trace(x.nodeName);
		at( !f.accept( new PlainPacket( x ) ) );
		*/
		
	}
	
	public function testFieldFilter() {
		var m = new Message();
		m.to = "node@disktree.net";
		m.from = "me@disktree.net";
		var f = new PacketFieldFilter( "to", "node@disktree.net" );
		at( f.accept( m ) );
		f = new PacketFieldFilter( "to" );
		at( f.accept( m ) );
		f = new PacketFieldFilter( "toooooooo" );
		af( f.accept( m ) );
	}
	
	public function testFilterReverse() {
		var f = new PacketFromFilter("node@domain.net");
		var r = new FilterReverse( f );
		var m = new Message();
		m.from = "node@domain.net";
		at( f.accept( m ) );
		af( r.accept( m ) );
		m.from = "any@domain.net";
		af( f.accept( m ) );
		at( r.accept( m ) );
	}
	
	public function testFilterGroup() {
		var m = new Message();
		m.from = "node@domain.net";
		var f1 = new PacketTypeFilter( PacketType.message );
		var f2 = new PacketTypeFilter( PacketType.presence );
		var group = new FilterGroup( [cast f1, cast f2] );
		at( group.accept( m ) );
		f2 = new PacketTypeFilter( PacketType.presence );
		group = new FilterGroup( [cast f2] );
		af( group.accept( m ) );
	}
	
}
