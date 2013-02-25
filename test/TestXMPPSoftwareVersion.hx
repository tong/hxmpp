
class TestXMPPSoftwareVersion extends TestCase {
	
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
		eq( "NORC", sv.name );
		eq( "0.7.0.4", sv.version );
		eq( "Windows-XP 5.01.2600", sv.os );
	}
	
	public function testBuild() {
		
		var sv = new xmpp.SoftwareVersion( "NORC", "1.0", "Linux" );
		eq( "NORC", sv.name );
		eq( "1.0", sv.version );
		eq( "Linux", sv.os );
		
		var x = sv.toXml();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "name" : eq( "NORC", e.firstChild().nodeValue );
			case "version" : eq( "1.0", e.firstChild().nodeValue );
			case "os" : eq( "Linux", e.firstChild().nodeValue );
			}
		}
	}
	
}
