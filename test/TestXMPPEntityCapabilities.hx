
class TestXMPPEntityCapabilities extends TestCase   {
	
	public function testParse() {
		var x = Xml.parse( "
			<presence>
			  <c xmlns='http://jabber.org/protocol/caps'
			     hash='sha-1'
			     node='http://code.google.com/p/hxmpp'
			     ver='QgayPKawpkPSDYmwT/WM94uAlu0='/>
			</presence>" ).firstElement();
		var caps = xmpp.Caps.parse( x.elements().next() );
		eq( "sha-1", caps.hash );
		eq( "http://code.google.com/p/hxmpp", caps.node );
		eq( "QgayPKawpkPSDYmwT/WM94uAlu0=", caps.ver );
		var p = xmpp.Presence.parse( x );
		caps = xmpp.Caps.fromPresence( p );
		eq( "sha-1", caps.hash );
		eq( "http://code.google.com/p/hxmpp", caps.node );
		eq( "QgayPKawpkPSDYmwT/WM94uAlu0=", caps.ver );
	}
	
	public function testBuild() {
		var c = new xmpp.Caps( "sha-1", "http://code.google.com/p/exodus", "QgayPKawpkPSDYmwT/WM94uAlu0=" );
		eq( "sha-1", c.hash );
		eq( "http://code.google.com/p/exodus", c.node );
		eq( "QgayPKawpkPSDYmwT/WM94uAlu0=", c.ver );
		var x = c.toXml();
		eq( "sha-1", x.get( "hash" ) );
		eq( "http://code.google.com/p/exodus", x.get( "node" ) );
		eq( "QgayPKawpkPSDYmwT/WM94uAlu0=", x.get( "ver" ) );
	}
	
}
