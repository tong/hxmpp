
import xmpp.XMLBeautify;

class TestXMLBeautify extends haxe.unit.TestCase {

	public function test() {
		var s = XMLBeautify.it( 'this is not xml, therefore not formatted' );
		assertEquals( 'this is not xml, therefore not formatted', s );
	}
	
}
