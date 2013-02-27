
class TestXMPPStreamError extends haxe.unit.TestCase {
	
	public function test() {
	
		var e1 = new xmpp.StreamError( "bad-format" ).toXml().toString();
		assertEquals( '<stream:error><bad-format xmlns="urn:ietf:params:xml:ns:xmpp-streams"/></stream:error>', e1 );
	
		var p1 = xmpp.StreamError.parse( Xml.parse( e1 ).firstElement() );
		assertEquals( "bad-format", p1.condition ); 
		
		var e2 = new xmpp.StreamError( "bad-format", "descriptive text" ).toXml().toString();
		assertEquals( '<stream:error><bad-format xmlns="urn:ietf:params:xml:ns:xmpp-streams"/><text xmlns="urn:ietf:params:xml:ns:xmpp-streams">descriptive text</text></stream:error>', e2 );
		
		var p2 = xmpp.StreamError.parse( Xml.parse( e2 ).firstElement() );
		assertEquals( "bad-format", p2.condition ); 
		assertEquals( "descriptive text", p2.text ); 
		
		var e3 = new xmpp.StreamError( "conflict", "descriptive text", "en", { condition : "mycond", xmlns : "http://disktree.net" } ).toXml().toString();
		
		var p3 = xmpp.StreamError.parse( Xml.parse( e3 ).firstElement() );
		assertEquals( "conflict", p3.condition ); 
		assertEquals( "descriptive text", p3.text ); 
		assertEquals( "mycond", p3.app.condition ); 
		assertEquals( "http://disktree.net", p3.app.xmlns ); 
		
		
		var x = Xml.parse( "<stream:error>
	<xml-not-well-formed xmlns='urn:ietf:params:xml:ns:xmpp-streams'/>
	<text xml:lang='en' xmlns='urn:ietf:params:xml:ns:xmpp-streams'>Some special application diagnostic information!</text>
	<escape-your-data xmlns='application-ns'/>
</stream:error>" ).firstElement();
		var e = xmpp.StreamError.parse( x );
		assertEquals( "xml-not-well-formed", e.condition );
		assertEquals( "Some special application diagnostic information!", e.text );
		assertEquals( "en", e.lang );
		assertEquals( "escape-your-data", e.app.condition );
		assertEquals( "application-ns", e.app.xmlns );
	}
	
}
