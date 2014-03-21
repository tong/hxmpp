
import xmpp.IQ;
import xmpp.IQType;

class TestXMPPIQPacket extends haxe.unit.TestCase {
	
	public function test_build() {
		
		var iq = new IQ( null, "123" );
		assertEquals( IQType.get, iq.type );
		assertEquals( "123", iq.id );
		assertEquals( null, iq.x );
		assertEquals( 0, iq.properties.length );
		assertEquals( IQType.get, iq.type );
		
		var x = iq.toXml();
		assertEquals( "get", x.get("type") );
		assertEquals( "123", x.get("id") );
	}

	public function test_parse() {
		
		var x = Xml.parse( '
<iq type="get" to="jabber.disktree.net" id="ab08a">
	<query xmlns="http://jabber.org/protocol/disco#info"/>
</iq>' ).firstElement();
		var iq : IQ = IQ.parse( x ); //cast xmpp.Packet.parse( src );
		assertEquals( IQType.get, iq.type );
		assertEquals( 'jabber.disktree.net', iq.to );
		assertEquals( 'ab08a', iq.id );
		assertEquals( '<query xmlns="http://jabber.org/protocol/disco#info"/>', iq.x.toXml().toString() );
		//assertEquals( 1, iq.properties.length );
		assertEquals( 0, iq.properties.length );
		assertTrue( (iq.x != null) );
		
		/*
		#if !flash //haXe 2.06 fuckup
		assertEquals( "http://jabber.org/protocol/disco#info", iq.properties[0].get( "xmlns" ) );
		#end
		*/
	}
	
}
