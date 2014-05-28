
import xmpp.Presence;

class TestXMPPPresencePacket extends haxe.unit.TestCase {
	
	public function test_create() {
		
		var p = new Presence();
		assertEquals( p.toString(), '<presence/>' );

		p.status = "";
		assertEquals( p.toString(), '<presence/>' );

		p.type = xmpp.PresenceType.subscribe;
		assertEquals( p.toString(), '<presence type="subscribe"/>' );
		
		p.show = xmpp.PresenceShow.dnd;
		assertEquals( '<presence type="subscribe"><show>dnd</show></presence>', p.toString() );
		
		p.status = "be right back";
		assertEquals( '<presence type="subscribe"><show>dnd</show><status>be right back</status></presence>', p.toString() );
		
		p.priority = 5;
		assertEquals( '<presence type="subscribe"><show>dnd</show><status>be right back</status><priority>5</priority></presence>', p.toString() );
	
		var p = new Presence();
		assertEquals( p.toString(), '<presence/>' );
	}
	
	public function test_parse() {
		
		var x = Xml.parse( '
			<presence>
				<show>away</show>
				<priority>5</priority>
				<c xmlns="http://jabber.org/protocol/caps" node="http://psi-im.org/caps" ver="0.11-dev-rev8" ext="cs ep-notify html"/>
			</presence>' ).firstElement();
		
		var p : Presence = cast xmpp.Packet.parse( x );
		assertEquals( 5, p.priority );
		assertEquals( PresenceShow.away, p.show );
		assertEquals( 1, p.properties.length );
		assertEquals( null, p.status );
		
		x = Xml.parse( '
			<presence>
				<show>away</show>
				<priority>5</priority>
				<status>mystatustext</status>
			</presence>' ).firstElement();
		p = Presence.parse( x );
		assertEquals( "mystatustext", p.status );

		var empty = "                   ";
		x = Xml.parse( '
			<presence>
				<status>$empty</status>
			</presence>' ).firstElement();
		p = Presence.parse( x );
		assertEquals( empty, p.status );
	}
}
