
class TestXMPPCompression extends TestCase {
		
	public function testParse() {
		var x = Xml.parse( '<compression xmlns="http://jabber.org/features/compress"><method>zlib</method></compression>' ).firstElement();
		var methods = xmpp.Compression.parseMethods( x );
		eq( 1, methods.length );
		eq( "zlib", methods[0] );
	}
	
	#if !flash //TODO
	
	public function testBuild() {
		var p = xmpp.Compression.createXml( ["zlib"] );
		eq( '<compress xmlns="http://jabber.org/protocol/compress"><method>zlib</method></compress>', p.toString() );
	}
	
	#end
		
}
