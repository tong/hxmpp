
class TestXMPPRegister extends TestCase {
	
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
		eq( r.username, 'juliet' );
		eq( r.password, 'R0m30' );
		eq( r.email, 'juliet@capulet.com' );
		eq( r.name, null );
	}
	
	public function testBuild() {
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
		eq( r.username, "tong" );
		eq( r.password, "test" );
		eq( r.email, "mail@domain.com" );
		eq( r.name, "myname" );
		var x = r.toXml();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "username" : eq( e.firstChild().nodeValue, "tong" );
			case "password" : eq( e.firstChild().nodeValue, "test" );
			case "email" : eq( e.firstChild().nodeValue, "mail@domain.com" );
			case "name" : eq( e.firstChild().nodeValue, "myname" );
			case "nick" : eq( e.firstChild().nodeValue, "t0ng" );
			case "first" : eq( e.firstChild().nodeValue, "roman" );
			case "last" : eq( e.firstChild().nodeValue, "polanski" );
			case "address" : eq( e.firstChild().nodeValue, "earth 293" );
			case "city" : eq( e.firstChild().nodeValue, "tokio" );
			case "state" : eq( e.firstChild().nodeValue, "iraq" );
			case "zip" : eq( e.firstChild().nodeValue, "1223" );
			case "phone" : eq( e.firstChild().nodeValue, "1234567" );
			case "url" : eq( e.firstChild().nodeValue, "http://disktree.net" );
			case "date" : eq( e.firstChild().nodeValue, "2012-23-23" );
			case "misc" : eq( e.firstChild().nodeValue, "misc" );
			case "text" : eq( e.firstChild().nodeValue, "sometext" );
			case "key" : eq( e.firstChild().nodeValue, "123" );
			}
		}
	}
	
}
