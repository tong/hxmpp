
class TestXMPPLastActivity extends haxe.unit.TestCase {
	
	public function testParse() {
		var q = Xml.parse( "<query xmlns='jabber:iq:last' seconds='903'/>" ).firstElement();
		var activity = xmpp.LastActivity.parse( q );
		assertEquals( 903, activity.seconds );
		var secs = xmpp.LastActivity.parseSeconds( q );
		assertEquals( 903, secs );
	}
	
	public function testBuild() {
		var x = new xmpp.LastActivity( 903 ).toXml();
		assertEquals( "903", x.get("seconds") );
	}
	
}
