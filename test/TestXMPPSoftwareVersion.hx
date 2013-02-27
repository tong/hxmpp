
class TestXMPPSoftwareVersion extends haxe.unit.TestCase {
	
	public function testParse() {
		var x = Xml.parse("
<iq
    type='result' to='romeo@montague.net/orchard' from='juliet@capulet.com/balcony' id='version_1'>
  <query xmlns='jabber:iq:version'>
    <name>NORC</name>
    <version>0.7.0.4</version>
    <os>Windows-XP 5.01.2600</os>
  </query>
</iq>" ).firstElement();
		var iq = xmpp.IQ.parse( x );
		var sv = xmpp.SoftwareVersion.parse( iq.x.toXml() );
		assertEquals( "NORC", sv.name );
		assertEquals( "0.7.0.4", sv.version );
		assertEquals( "Windows-XP 5.01.2600", sv.os );
	}
	
	public function testBuild() {
		
		var sv = new xmpp.SoftwareVersion( "NORC", "1.0", "Linux" );
		assertEquals( "NORC", sv.name );
		assertEquals( "1.0", sv.version );
		assertEquals( "Linux", sv.os );
		
		var x = sv.toXml();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "name" : assertEquals( "NORC", e.firstChild().nodeValue );
			case "version" : assertEquals( "1.0", e.firstChild().nodeValue );
			case "os" : assertEquals( "Linux", e.firstChild().nodeValue );
			}
		}
	}
	
}
