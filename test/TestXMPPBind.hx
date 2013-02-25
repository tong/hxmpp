
class TestXMPPBind extends TestCase {
	
	public function testBuild() {
		
		var p = new xmpp.Bind( "MyResource" );
		eq( "MyResource", p.resource );
		eq( null, p.jid );
		var x = p.toXml();
		#if !flash //TODO
		eq( 'urn:ietf:params:xml:ns:xmpp-bind', x.get("xmlns"));
		#end
		eq( 'resource', x.firstChild().nodeName );
		eq( 'MyResource', x.firstChild().firstChild().nodeValue );
	}
	
	public function testParse() {
	
		var x = Xml.parse( '<bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">
	<resource>HXMPPConsoleDemo</resource>
</bind>' ).firstElement();
		var b = xmpp.Bind.parse(x);
		eq( 'HXMPPConsoleDemo', b.resource );
		eq( null, b.jid );
	}
	
}
