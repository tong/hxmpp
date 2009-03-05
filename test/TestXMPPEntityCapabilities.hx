
/**
	Testunit for xmpp.Caps
*/
class TestXMPPEntityCapabilities extends haxe.unit.TestCase   {
	
	public function testParsing() {
		
		var xml = Xml.parse( "<presence>
  <c xmlns='http://jabber.org/protocol/caps'
     hash='sha-1'
     node='http://code.google.com/p/hxmpp'
     ver='QgayPKawpkPSDYmwT/WM94uAlu0='/>
</presence>" ).firstElement();
		
		var caps = xmpp.Caps.parse( xml.elements().next() );
		assertEquals( "sha-1", caps.hash );
		assertEquals( "http://code.google.com/p/hxmpp", caps.node );
		assertEquals( "QgayPKawpkPSDYmwT/WM94uAlu0=", caps.ver );
		
		var p = xmpp.Presence.parse( xml );
		caps = xmpp.Caps.fromPresence( p );
		assertEquals( "sha-1", caps.hash );
		assertEquals( "http://code.google.com/p/hxmpp", caps.node );
		assertEquals( "QgayPKawpkPSDYmwT/WM94uAlu0=", caps.ver );
		
	}
	
}
