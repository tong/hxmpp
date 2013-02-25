
class TestXMPPError extends TestCase {
	
	public function testParse() {
		
		var e = xmpp.Error.parse( Xml.parse( '<error type="cancel"><conflict xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error>' ).firstElement() );
		
		eq( e.type, xmpp.ErrorType.cancel );
		eq( e.condition, "conflict");
		eq( e.code, null );
		eq( e.text, null );
		eq( e.lang, null );
		eq( e.app, null );
		
		e = xmpp.Error.parse( Xml.parse( '<error code="501" type="cancel"><sta:feature-not-implemented xmlns:sta="urn:ietf:params:xml:ns:xmpp-stanzas"></sta:feature-not-implemented></error>' ).firstElement() );
		eq( e, null );
		
		e = xmpp.Error.parse( Xml.parse( '<error code="501" type="cancel"><feature-not-implemented xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"></feature-not-implemented></error>' ).firstElement() );
		eq( e.code, 501 );
		eq( e.type, xmpp.ErrorType.cancel );
		eq( "feature-not-implemented", e.condition );
	}
	
	public function testBuild() {
		
		var e = new xmpp.Error( xmpp.ErrorType.cancel, "bad-request" );
		#if !flash //TODO flash
		eq( '<error type="cancel"><bad-request xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error>', e.toXml().toString() );
		#end
		eq( e.type, xmpp.ErrorType.cancel );
		eq( e.condition, "bad-request" );
		
		var e = new xmpp.Error( xmpp.ErrorType.cancel, "conflict", 123 );
		e.lang = "en";
		e.app = { xmlns : "http://disktree.net", condition : "app-specific-error" };
		var x = e.toXml();
		eq( 'cancel', x.get("type") );
		eq( '123', x.get("code") );
		eq( 'conflict', x.firstElement().nodeName );
		#if !flash //TODO flash
		eq( 'urn:ietf:params:xml:ns:xmpp-stanzas', x.firstElement().get("xmlns") );
		#end
	}
	
}
