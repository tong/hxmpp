
/**
	Testunit for xmpp.DataForm
*/
class TestXMPPPrivateStorage extends haxe.unit.TestCase {
	
	public function test_create_parse() {
		var p = new xmpp.PrivateStorage( "exodus", "exodus:prefs", Xml.parse( "<defaultnick>Hamlet</defaultnick>" ).firstElement() );
		var s = xmpp.PrivateStorage.parse( p.toXml() );
		assertEquals( "exodus", s.name );
		assertEquals( "exodus:prefs", s.namespace );
		assertEquals( "<defaultnick>Hamlet</defaultnick>", s.data.toString() );
	}
	
}
