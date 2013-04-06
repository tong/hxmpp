
class TestXMPPError extends haxe.unit.TestCase {
	
	public function testParse() {
		
		var e = xmpp.Error.parse( Xml.parse( '<error type="cancel"><conflict xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error>' ).firstElement() );
		
		assertEquals( e.type, xmpp.ErrorType.cancel );
		assertEquals( e.condition, "conflict");
		assertEquals( e.code, null );
		assertEquals( e.text, null );
		assertEquals( e.lang, null );
		assertEquals( e.app, null );
		
		e = xmpp.Error.parse( Xml.parse( '<error code="501" type="cancel"><sta:feature-not-implemented xmlns:sta="urn:ietf:params:xml:ns:xmpp-stanzas"></sta:feature-not-implemented></error>' ).firstElement() );
		assertEquals( e, null );
		
		e = xmpp.Error.parse( Xml.parse( '<error code="501" type="cancel"><feature-not-implemented xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"></feature-not-implemented></error>' ).firstElement() );
		assertEquals( e.code, 501 );
		assertEquals( e.type, xmpp.ErrorType.cancel );
		assertEquals( "feature-not-implemented", e.condition );
	}
	
	public function testBuild() {
		
		var e = new xmpp.Error( xmpp.ErrorType.cancel, "bad-rassertEqualsuest" );
		#if !flash //TODO flash
		assertEquals( '<error type="cancel"><bad-rassertEqualsuest xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error>', e.toXml().toString() );
		#end
		assertEquals( e.type, xmpp.ErrorType.cancel );
		assertEquals( e.condition, "bad-rassertEqualsuest" );
		
		var e = new xmpp.Error( xmpp.ErrorType.cancel, "conflict", 123 );
		e.lang = "en";
		e.app = { xmlns : "http://disktree.net", condition : "app-specific-error" };
		var x = e.toXml();
		assertEquals( 'cancel', x.get("type") );
		assertEquals( '123', x.get("code") );
		assertEquals( 'conflict', x.firstElement().nodeName );
		#if !flash //TODO flash
		assertEquals( 'urn:ietf:params:xml:ns:xmpp-stanzas', x.firstElement().get("xmlns") );
		#end
	}
	
}
