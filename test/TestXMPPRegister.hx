
/**
	Testunit for xmpp.Register
*/
class TestXMPPRegister extends haxe.unit.TestCase {
	
	public function testParsing() {
		var iq = xmpp.IQ.parse( Xml.parse(
		"<iq type='result' id='reg1'>
			<query xmlns='jabber:iq:register'>
   				<registered/>
				<username>juliet</username>
   				<password>R0m30</password>
				<email>juliet@capulet.com</email>
			</query>
		</iq>" ).firstElement() );
		var r = xmpp.Register.parse( iq.ext.toXml() );
		assertEquals( r.username, 'juliet' );
		assertEquals( r.password, 'R0m30' );
		assertEquals( r.email, 'juliet@capulet.com' );
		assertEquals( r.name, null );
	}
	
	public function testCreation() {
		var r = new xmpp.Register( "tong", "test", "mail@domain.com", "myname" );
		assertEquals( r.username, "tong" );
		assertEquals( r.password, "test" );
		assertEquals( r.email, "mail@domain.com" );
		assertEquals( r.name, "myname" );
	}
	
}
