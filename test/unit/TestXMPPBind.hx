
class TestXMPPBind extends haxe.unit.TestCase {
	
	public function testBuild() {
		
		var p = new xmpp.Bind( "MyResource" );
		assertEquals( "MyResource", p.resource );
		assertEquals( null, p.jid );
		var x = p.toXml();
		#if !flash //TODO
		assertEquals( 'urn:ietf:params:xml:ns:xmpp-bind', x.get("xmlns"));
		#end
		assertEquals( 'resource', x.firstChild().nodeName );
		assertEquals( 'MyResource', x.firstChild().firstChild().nodeValue );
	}
	
	public function testParse() {
	
		var x = Xml.parse( '<bind xmlns="urn:ietf:params:xml:ns:xmpp-bind">
	<resource>HXMPPConsoleDemo</resource>
</bind>' ).firstElement();
		var b = xmpp.Bind.parse(x);
		assertEquals( 'HXMPPConsoleDemo', b.resource );
		assertEquals( null, b.jid );
	}
	
}
