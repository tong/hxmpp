
/**
	Testunit for xmpp.Auth
*/
class TestXMPPAuth extends haxe.unit.TestCase {
	
	public function testParse() {
		var iq = xmpp.IQ.parse( Xml.parse( '<iq id="A8Q8u1" type="get"><query xmlns="jabber:iq:auth"><username>hxmpp</username></query></iq>' ).firstElement() );
		var auth = xmpp.Auth.parse( iq.x.toXml() );
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
		auth = xmpp.Auth.parse( iq.x.toXml() );
		assertEquals( auth.username, 'tong' );
		assertEquals( auth.password, 'test' );
		assertEquals( auth.resource, 'norc' );
		assertEquals( auth.digest, "123" );
	}
	
	public function testBuild() {
		
		var a = new xmpp.Auth( "tong", "test", "123", "hxmpp" );
		assertEquals( "tong", a.username );
		assertEquals( "test",  a.password );
		assertEquals( "123",a.digest );
		assertEquals( "hxmpp", a.resource );
		
		/*
		var s = haxe.Timer.stamp();
		for( i in 0...10000 ) {
			var x = a.toXml();
		}
		trace(haxe.Timer.stamp()-s);
		return;
		*/
		var x = a.toXml();
		
		assertEquals( 4, Lambda.count( x ) );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "username" : assertEquals( "tong", e.firstChild().nodeValue );
			case "password" : assertEquals( "test", e.firstChild().nodeValue );
			case "digest" : assertEquals( "123", e.firstChild().nodeValue );
			case "resource" : assertEquals( "hxmpp", e.firstChild().nodeValue );
			default : assertTrue(false);
			}
		}
	}
	
}