
class TestXMPPEntityTime extends TestCase {
	
	public function testParse() {
		var x = Xml.parse( "
			<time xmlns='urn:xmpp:time'>
			    <tzo>-06:00</tzo>
			    <utc>2006-12-19T17:58:35Z</utc>
			</time>" ).firstElement();
		var t = xmpp.EntityTime.parse( x );
		eq( "-06:00", t.tzo );
		eq( "2006-12-19T17:58:35Z", t.utc );
	}
	
	public function testBuild() {
		var p = new xmpp.EntityTime( "2006-12-19T17:58:35Z" );
		var x = p.toXml();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "utc" : eq( e.firstChild().nodeValue, p.utc );
			case "tzo" : eq( null, p.tzo );
			}
		}
	}
	
}
