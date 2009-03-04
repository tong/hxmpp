
/**
	Testunit for xmpp.Caps
*/
class TestXMPPCaps extends haxe.unit.TestCase {
	
	public function testParsing() {
		var x = Xml.parse( "
<presence from='romeo@montague.lit/orchard'>
  <c xmlns='http://jabber.org/protocol/caps' 
     hash='sha-1'
     node='http://code.google.com/p/exodus'
     ver='QgayPKawpkPSDYmwT/WM94uAlu0='/>
</presence>" ).firstElement();
		var p = xmpp.Presence.parse( x );
		var c = xmpp.Caps.parse( p.properties[0] );
		assertEquals( "sha-1", c.hash );
		assertEquals( "http://code.google.com/p/exodus", c.node );
		assertEquals( "QgayPKawpkPSDYmwT/WM94uAlu0=", c.ver );
	}
	
	public function testCreation() {
		var c = new xmpp.Caps( "sha-1", "http://code.google.com/p/exodus", "QgayPKawpkPSDYmwT/WM94uAlu0=" );
		assertEquals( "sha-1", c.hash );
		assertEquals( "http://code.google.com/p/exodus", c.node );
		assertEquals( "QgayPKawpkPSDYmwT/WM94uAlu0=", c.ver );
		var x = c.toXml();
		assertEquals( "sha-1", x.get( "hash" ) );
		assertEquals( "http://code.google.com/p/exodus", x.get( "node" ) );
		assertEquals( "QgayPKawpkPSDYmwT/WM94uAlu0=", x.get( "ver" ) );
	}
	
}
