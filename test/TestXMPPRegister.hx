
/**
	Testunit for xmpp.Register
*/
class TestXMPPRegister extends haxe.unit.TestCase {
	
	public function testParse() {
		var iq = xmpp.IQ.parse( Xml.parse(
		"<iq type='result' id='reg1'>
			<query xmlns='jabber:iq:register'>
   				<registered/>
				<username>juliet</username>
   				<password>R0m30</password>
				<email>juliet@capulet.com</email>
			</query>
		</iq>" ).firstElement() );
		var r = xmpp.Register.parse( iq.x.toXml() );
		assertEquals( r.username, 'juliet' );
		assertEquals( r.password, 'R0m30' );
		assertEquals( r.email, 'juliet@capulet.com' );
		assertEquals( r.name, null );
	}
	
	public function testCreate() {
		var r = new xmpp.Register( "tong", "test", "mail@domain.com", "myname" );
		r.nick = "t0ng";
		r.first = "roman";
		r.last = "polanski";
		r.address = "earth 293";
		r.city = "tokio";
		r.state = "iraq";
		r.zip = "1223";
		r.phone = "1234567";
		r.url = "http://disktree.net";
		r.date = "2012-23-23";
		r.misc = "misc";
		r.text = "sometext";
		r.key = "123";
		assertEquals( r.username, "tong" );
		assertEquals( r.password, "test" );
		assertEquals( r.email, "mail@domain.com" );
		assertEquals( r.name, "myname" );
		var x = r.toXml();
		for( e in x.elements() ) {
			//trace(e);
			switch( e.nodeName ) {
			case "username" : assertEquals( e.firstChild().nodeValue, "tong" );
			case "password" : assertEquals( e.firstChild().nodeValue, "test" );
			case "email" : assertEquals( e.firstChild().nodeValue, "mail@domain.com" );
			case "name" : assertEquals( e.firstChild().nodeValue, "myname" );
			case "nick" : assertEquals( e.firstChild().nodeValue, "t0ng" );
			case "first" : assertEquals( e.firstChild().nodeValue, "roman" );
			case "last" : assertEquals( e.firstChild().nodeValue, "polanski" );
			case "address" : assertEquals( e.firstChild().nodeValue, "earth 293" );
			case "city" : assertEquals( e.firstChild().nodeValue, "tokio" );
			case "state" : assertEquals( e.firstChild().nodeValue, "iraq" );
			case "zip" : assertEquals( e.firstChild().nodeValue, "1223" );
			case "phone" : assertEquals( e.firstChild().nodeValue, "1234567" );
			case "url" : assertEquals( e.firstChild().nodeValue, "http://disktree.net" );
			case "date" : assertEquals( e.firstChild().nodeValue, "2012-23-23" );
			case "misc" : assertEquals( e.firstChild().nodeValue, "misc" );
			case "text" : assertEquals( e.firstChild().nodeValue, "sometext" );
			case "key" : assertEquals( e.firstChild().nodeValue, "123" );
			}
		}
	}
	
}
