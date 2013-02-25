
/**
*/
class TestXMPPBOB extends TestCase {

	public function testParse() {
		var x = Xml.parse("<data xmlns='urn:xmpp:bob' max-age='86400' type='image/png' cid='sha1+8f35fef110ffc5df08d579a50083ff9308fb6242@bob.xmpp.org'>123</data>" ).firstElement();
		var bob = xmpp.BOB.parse( x );
		eq( "sha1+8f35fef110ffc5df08d579a50083ff9308fb6242@bob.xmpp.org", bob.cid );
		eq( "image/png", bob.type );
		eq( 86400, bob.max_age );
		eq( "123", bob.data );
		var cid = xmpp.BOB.getCIDParts( bob.cid );
		eq( "sha1", cid[0] );
		eq( "8f35fef110ffc5df08d579a50083ff9308fb6242", cid[1] );
	}
	
	public function testBuild() {
		var x = new xmpp.BOB( "sha1+8f35fef110ffc5df08d579a50083ff9308fb6242@bob.xmpp.org", "image/png", 86400, "123" ).toXml();
		eq( "sha1+8f35fef110ffc5df08d579a50083ff9308fb6242@bob.xmpp.org", x.get("cid") );
		eq( "image/png", x.get("type") );
		eq( "86400", x.get("max-age") );
		eq( "urn:xmpp:bob", x.get("xmlns") );
		eq( "123", x.firstChild().nodeValue );
	}
	
}
