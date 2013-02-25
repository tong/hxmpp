
class TestXMPPSASL extends TestCase {
	
		#if !flash //TODO flash
	public function testParse() {
		
		var x = xmpp.SASL.createAuth( "MD5-DIGEST"  );
		eq( 'auth', x.nodeName );
		eq( 'urn:ietf:params:xml:ns:xmpp-sasl', x.get('xmlns') );
		eq( 'MD5-DIGEST', x.get('mechanism') );

		//TODO
		
		/*
		var x = Xml.parse( '<stream:features>
<starttls xmlns="urn:ietf:params:xml:ns:xmpp-tls"/>
<mechanisms xmlns="urn:ietf:params:xml:ns:xmpp-sasl">
<mechanism>DIGEST-MD5</mechanism>
<mechanism>PLAIN</mechanism>
</mechanisms>
<register xmlns="http://jabber.org/features/iq-register"/>
</stream:features>' );
*/
		
	}
		#end
	
}
