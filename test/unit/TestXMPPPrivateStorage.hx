
class TestXMPPPrivateStorage extends haxe.unit.TestCase {
	
	public function testParse() {
		var s = xmpp.PrivateStorage.parse( Xml.parse( '<query xmlns="jabber:iq:private">
	<exodus xmlns="exodus:prefs">
		<defaultnick>Macbeth</defaultnick>
	</exodus>
</query>' ).firstElement() );
		assertEquals( "exodus", s.name );
		assertEquals( "exodus:prefs", s.namespace );
		assertEquals( "<defaultnick>Macbeth</defaultnick>", s.data.toString() );
	}
	
	public function testBuild() {
		var x = new xmpp.PrivateStorage( "exodus", "exodus:prefs", Xml.parse( "<defaultnick>Macbeth</defaultnick>" ).firstElement() ).toXml().firstElement();
		assertEquals( "exodus", x.nodeName );
		assertEquals( "exodus:prefs", x.get("xmlns") );
		assertEquals( "<defaultnick>Macbeth</defaultnick>", x.firstElement().toString() );
	}
	
}
