
/**
*/
class TestXMPPBOB extends haxe.unit.TestCase {

	public function testParse() {
		var x = Xml.parse("<data xmlns='urn:xmpp:bob' max-age='86400' type='image/png' cid='sha1+8f35fef110ffc5df08d579a50083ff9308fb6242@bob.xmpp.org'>123</data>" ).firstElement();
		var bob = xmpp.BOB.parse( x );
		assertEquals( "sha1+8f35fef110ffc5df08d579a50083ff9308fb6242@bob.xmpp.org", bob.cid );
		assertEquals( "image/png", bob.type );
		assertEquals( 86400, bob.max_age );
		assertEquals( "123", bob.data );
		var cid = xmpp.BOB.getCIDParts( bob.cid );
		assertEquals( "sha1", cid[0] );
		assertEquals( "8f35fef110ffc5df08d579a50083ff9308fb6242", cid[1] );
	}

}
