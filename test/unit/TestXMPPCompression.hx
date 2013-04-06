
class TestXMPPCompression extends haxe.unit.TestCase {
		
	public function testParse() {
		var x = Xml.parse( '<compression xmlns="http://jabber.org/features/compress"><method>zlib</method></compression>' ).firstElement();
		var methods = xmpp.Compression.parseMethods( x );
		assertEquals( 1, methods.length );
		assertEquals( "zlib", methods[0] );
	}
	
	#if !flash //TODO
	
	public function testBuild() {
		var p = xmpp.Compression.createXml( ["zlib"] );
		assertEquals( '<compress xmlns="http://jabber.org/protocol/compress"><method>zlib</method></compress>', p.toString() );
	}
	
	#end
		
}
