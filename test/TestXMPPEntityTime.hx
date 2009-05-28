
/**
	Testunit for xmpp.EntityTime
*/
class TestXMPPEntityTime extends haxe.unit.TestCase {
	
	public function testParse() {
		var x = Xml.parse( "
			<time xmlns='urn:xmpp:time'>
			    <tzo>-06:00</tzo>
			    <utc>2006-12-19T17:58:35Z</utc>
			</time>" ).firstElement();
		var t = xmpp.EntityTime.parse( x );
		assertEquals( "-06:00", t.tzo );
		assertEquals( "2006-12-19T17:58:35Z", t.utc );
	}
	
}
