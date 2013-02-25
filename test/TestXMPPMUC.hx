
class TestXMPPMUC extends TestCase   {
		
	public function testParse() {
		
		var decline = xmpp.muc.Decline.parse( Xml.parse( "<decline to='crone1@shakespeare.lit'>
      <reason>Sorry, I'm too busy right now.</reason>
    </decline>" ).firstElement() );
		
		assertEquals( 'crone1@shakespeare.lit', decline.to );
		assertEquals( null, decline.from );
		assertEquals( "Sorry, I'm too busy right now.", decline.reason );
		
		//TODO
		//.....
	}
	
}
