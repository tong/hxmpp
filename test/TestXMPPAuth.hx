
/**
	Testunit for xmpp.Auth
*/
class TestXMPPAuth extends TestCase {
	
	public function testParse() {
		var iq = xmpp.IQ.parse( Xml.parse( '<iq id="A8Q8u1" type="get"><query xmlns="jabber:iq:auth"><username>hxmpp</username></query></iq>' ).firstElement() );
		var auth = xmpp.Auth.parse( iq.x.toXml() );
		eq( auth.username, 'hxmpp' );
		eq( auth.password, null );
		eq( auth.resource, null );
		eq( auth.digest, null );
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
		eq( auth.username, 'tong' );
		eq( auth.password, 'test' );
		eq( auth.resource, 'norc' );
		eq( auth.digest, "123" );
	}
	
	public function testBuild() {
		
		var a = new xmpp.Auth( "tong", "test", "123", "hxmpp" );
		eq( "tong", a.username );
		eq( "test",  a.password );
		eq( "123",a.digest );
		eq( "hxmpp", a.resource );
		
		/*
		var s = haxe.Timer.stamp();
		for( i in 0...10000 ) {
			var x = a.toXml();
		}
		trace(haxe.Timer.stamp()-s);
		return;
		*/
		var x = a.toXml();
		
		eq( 4, Lambda.count( x ) );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "username" : eq( "tong", e.firstChild().nodeValue );
			case "password" : eq( "test", e.firstChild().nodeValue );
			case "digest" : eq( "123", e.firstChild().nodeValue );
			case "resource" : eq( "hxmpp", e.firstChild().nodeValue );
			default : assertTrue(false);
			}
		}
	}
	
}