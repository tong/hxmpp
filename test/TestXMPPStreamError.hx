
class TestXMPPStreamError extends TestCase {
	
	public function test() {
	
		var e1 = new xmpp.StreamError( "bad-format" ).toXml().toString();
		eq( '<stream:error><bad-format xmlns="urn:ietf:params:xml:ns:xmpp-streams"/></stream:error>', e1 );
	
		var p1 = xmpp.StreamError.parse( Xml.parse( e1 ).firstElement() );
		eq( "bad-format", p1.condition ); 
		
		var e2 = new xmpp.StreamError( "bad-format", "descriptive text" ).toXml().toString();
		eq( '<stream:error><bad-format xmlns="urn:ietf:params:xml:ns:xmpp-streams"/><text xmlns="urn:ietf:params:xml:ns:xmpp-streams">descriptive text</text></stream:error>', e2 );
		
		var p2 = xmpp.StreamError.parse( Xml.parse( e2 ).firstElement() );
		eq( "bad-format", p2.condition ); 
		eq( "descriptive text", p2.text ); 
		
		var e3 = new xmpp.StreamError( "conflict", "descriptive text", "en", { condition : "mycond", xmlns : "http://disktree.net" } ).toXml().toString();
		
		var p3 = xmpp.StreamError.parse( Xml.parse( e3 ).firstElement() );
		eq( "conflict", p3.condition ); 
		eq( "descriptive text", p3.text ); 
		eq( "mycond", p3.app.condition ); 
		eq( "http://disktree.net", p3.app.xmlns ); 
		
		
		var x = Xml.parse( "<stream:error>
	<xml-not-well-formed xmlns='urn:ietf:params:xml:ns:xmpp-streams'/>
	<text xml:lang='en' xmlns='urn:ietf:params:xml:ns:xmpp-streams'>Some special application diagnostic information!</text>
	<escape-your-data xmlns='application-ns'/>
</stream:error>" ).firstElement();
		var e = xmpp.StreamError.parse( x );
		eq( "xml-not-well-formed", e.condition );
		eq( "Some special application diagnostic information!", e.text );
		eq( "en", e.lang );
		eq( "escape-your-data", e.app.condition );
		eq( "application-ns", e.app.xmlns );
	}
	
}
