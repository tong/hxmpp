
class TestXMPPEntityCapabilities extends haxe.unit.TestCase {
	
	public function testParse() {
		var x = Xml.parse( "
			<presence>
			  <c xmlns='http://jabber.org/protocol/caps'
			     hash='sha-1'
			     node='http://code.google.com/p/hxmpp'
			     ver='QgayPKawpkPSDYmwT/WM94uAlu0='/>
			</presence>" ).firstElement();
		var caps = xmpp.Caps.parse( x.elements().next() );
		assertEquals( "sha-1", caps.hash );
		assertEquals( "http://code.google.com/p/hxmpp", caps.node );
		assertEquals( "QgayPKawpkPSDYmwT/WM94uAlu0=", caps.ver );
		var p = xmpp.Presence.parse( x );
		caps = xmpp.Caps.fromPresence( p );
		assertEquals( "sha-1", caps.hash );
		assertEquals( "http://code.google.com/p/hxmpp", caps.node );
		assertEquals( "QgayPKawpkPSDYmwT/WM94uAlu0=", caps.ver );
	}
	
	public function testBuild() {
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
