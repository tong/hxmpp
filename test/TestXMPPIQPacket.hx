
import xmpp.IQ;
import xmpp.IQType;

class TestXMPPIQPacket extends TestCase {
	
	public function testBuild() {
		var iq = new xmpp.IQ( null, "123" );
		eq( IQType.get, iq.type );
		eq( "123", iq.id );
		eq( null, iq.x );
		eq( 0, iq.properties.length );
		eq( IQType.get, iq.type );
		var x = iq.toXml();
		eq( "get", x.get("type") );
		eq( "123", x.get("id") );
	}

	public function testParse() {
		var x = Xml.parse( '
<iq type="get" to="jabber.spektral.at" id="ab08a">
	<query xmlns="http://jabber.org/protocol/disco#info"/>
</iq>' ).firstElement();
		var iq : xmpp.IQ = xmpp.IQ.parse( x ); //cast xmpp.Packet.parse( src );
		eq( get, iq.type );
		eq( 'jabber.spektral.at', iq.to );
		eq( 'ab08a', iq.id );
		eq( '<query xmlns="http://jabber.org/protocol/disco#info"/>', iq.x.toXml().toString() );
		//eq( 1, iq.properties.length );
		eq( 0, iq.properties.length );
		assertTrue( (iq.x != null) );
		/*
#if !flash //haXe 2.06 fuckup
		eq( "http://jabber.org/protocol/disco#info", iq.properties[0].get( "xmlns" ) );
#end
	*/
	}
	
}
