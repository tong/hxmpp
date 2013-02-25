
/**
	Testunit for xmpp.LastActivity
*/
class TestXMPPLastActivity extends TestCase {
	
	public function testParse() {
		var q = Xml.parse( "<query xmlns='jabber:iq:last' seconds='903'/>" ).firstElement();
		var activity = xmpp.LastActivity.parse( q );
		eq( 903, activity.seconds );
		var secs = xmpp.LastActivity.parseSeconds( q );
		eq( 903, secs );
	}
	
	public function testBuild() {
		var x = new xmpp.LastActivity( 903 ).toXml();
		eq( "903", x.get("seconds") );
	}
	
}
