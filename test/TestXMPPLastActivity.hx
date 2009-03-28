
/**
	Testunit for xmpp.LastActivity
*/
class TestXMPPLastActivity extends haxe.unit.TestCase {
	
	public function testParse() {
		var q = Xml.parse( "<query xmlns='jabber:iq:last' seconds='903'/>" ).firstElement();
		var activity = xmpp.LastActivity.parse( q );
		var secs = xmpp.LastActivity.parseSeconds( q );
		assertEquals( 903, activity.seconds );
		assertEquals( 903, secs );
	}
	
}
