
/**
	Testunit for xmpp.Auth
*/
class TestXMPPAuth extends haxe.unit.TestCase {
	
	public function testParsing() {
		
		var iq = xmpp.IQ.parse( Xml.parse( '<iq id="A8Q8u1" type="get"><query xmlns="jabber:iq:auth"><username>hxmpp</username></query></iq>' ).firstElement() );
		var auth = xmpp.Auth.parse( iq.ext.toXml() );
		assertEquals( auth.username, 'hxmpp' );
		assertEquals( auth.password, null );
		assertEquals( auth.resource, null );
		assertEquals( auth.digest, null );
		
		iq = xmpp.IQ.parse( Xml.parse(
		'<iq type="set" id="66ceE3">
			<query xmlns="jabber:iq:auth">
				<username>tong</username>
				<password>test</password>
				<resource>norc</resource>
				<digest>123</digest>
			</query>
		</iq>' ).firstElement() );
		auth = xmpp.Auth.parse( iq.ext.toXml() );
		assertEquals( auth.username, 'tong' );
		assertEquals( auth.password, 'test' );
		assertEquals( auth.resource, 'norc' );
		assertEquals( auth.digest, "123" );
	}
	
	public function testCreation() {
		var a = new xmpp.Auth( "tong", "test", "123", "hxmpp" );
		assertEquals( a.username, "tong" );
		assertEquals( a.password, "test" );
		assertEquals( a.digest, "123" );
		assertEquals( a.resource, "hxmpp" );
	}
	
}