
class TestXMPPPrivateStorage extends TestCase {
	
	public function testParse() {
		var s = xmpp.PrivateStorage.parse( Xml.parse( '<query xmlns="jabber:iq:private">
	<exodus xmlns="exodus:prefs">
		<defaultnick>Macbeth</defaultnick>
	</exodus>
</query>' ).firstElement() );
		eq( "exodus", s.name );
		eq( "exodus:prefs", s.namespace );
		eq( "<defaultnick>Macbeth</defaultnick>", s.data.toString() );
	}
	
	public function testBuild() {
		var x = new xmpp.PrivateStorage( "exodus", "exodus:prefs", Xml.parse( "<defaultnick>Macbeth</defaultnick>" ).firstElement() ).toXml().firstElement();
		eq( "exodus", x.nodeName );
		eq( "exodus:prefs", x.get("xmlns") );
		eq( "<defaultnick>Macbeth</defaultnick>", x.firstElement().toString() );
	}
	
}
