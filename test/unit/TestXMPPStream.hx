
class TestXMPPStream extends haxe.unit.TestCase {
	
	public function test() {
		
		var s1 = xmpp.Stream.createOpenXml( xmpp.Stream.CLIENT, "server.com" );
		assertEquals( '<?xml version="1.0" encoding="UTF-8"?><stream:stream xmlns="jabber:client" xmlns:stream="http://etherx.jabber.org/streams" to="server.com" xmlns:xml="http://www.w3.org/XML/1998/namespace">', s1 );
		
		var s2 = xmpp.Stream.createOpenXml( xmpp.Stream.CLIENT, "server.com", true, "en" );
		assertEquals( '<?xml version="1.0" encoding="UTF-8"?><stream:stream xmlns="jabber:client" xmlns:stream="http://etherx.jabber.org/streams" to="server.com" xmlns:xml="http://www.w3.org/XML/1998/namespace" version="1.0" xml:lang="en">', s2 );
	}
	
}
