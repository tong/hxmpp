

class TestXMPPStreamError extends haxe.unit.TestCase   {
	
	public function testParsing() {
		
		var xml = Xml.parse("<stream:error>
  <xml-not-well-formed
      xmlns='urn:ietf:params:xml:ns:xmpp-streams'/>
  <text xml:lang='en' xmlns='urn:ietf:params:xml:ns:xmpp-streams'>Some special application diagnostic information!</text>
  <escape-your-data xmlns='application-ns'/>
</stream:error>" ).firstElement();
		
		var e = xmpp.StreamError.parse( xml );
		assertEquals( "xml-not-well-formed", e.condition );
		assertEquals( "Some special application diagnostic information!", e.text );
		assertEquals( "escape-your-data", e.app.condition );
		assertEquals( "application-ns", e.app.ns );
	}
	
}
