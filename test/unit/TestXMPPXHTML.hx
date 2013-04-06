
class TestXMPPXHTML extends haxe.unit.TestCase {
	
	public function testParse() {
		
		/*
		var x = Xml.parse('<blockquote>&quot;A foolish consistency is the hobgoblin of little minds.&quot;</blockquote>');
		trace(x);
		assertTrue(true);
		*/
		
		var xhtml : xmpp.XHTML = null;
		
		var x = Xml.parse(
"<message>
  <body>Wow, I&apos;m green with envy!</body>
  <html xmlns='http://jabber.org/protocol/xhtml-im'>
    <body xmlns='http://www.w3.org/1999/xhtml'><strong>envy</strong>!</body>
  </html>
</message>" ).firstElement();
		var m = xmpp.Message.parse( x );
		var body = xmpp.XHTML.fromMessage( m );
		assertEquals( "<strong>envy</strong>!", body );
		for( p in m.properties ) {
			if( p.nodeName == "html" && p.get( "xmlns" ) == xmpp.XHTML.XMLNS ) {
				xhtml = xmpp.XHTML.parse( p );
				break;
			}
		}
		assertEquals( "<strong>envy</strong>!", xhtml.body );
		
		var x = Xml.parse(
"<message>
  <body>As Emerson said in his essay Self-Reliance:&quot;A foolish consistency is the hobgoblin of little minds.&quot;</body>
  <html xmlns='http://jabber.org/protocol/xhtml-im'>
    <body xmlns='http://www.w3.org/1999/xhtml'><p>As Emerson said in his essay <cite>Self-Reliance</cite>:</p><blockquote>&quot;A foolish consistency is the hobgoblin of little minds.&quot;</blockquote></body>
  </html>
</message>" ).firstElement();
		
		//TODO !!!!!!!!!!!!!!!!!!!!! fails on ccpp, neko, js
		
		m = xmpp.Message.parse( x );
		body = xmpp.XHTML.fromMessage( m );
		assertEquals( "<p>As Emerson said in his essay <cite>Self-Reliance</cite>:</p><blockquote>&quot;A foolish consistency is the hobgoblin of little minds.&quot;</blockquote>", body );
		for( p in m.properties ) {
			if( p.nodeName == "html" && p.get( "xmlns" ) == xmpp.XHTML.XMLNS ) {
				xhtml = xmpp.XHTML.parse( p );
				break;
			}
		}
		assertEquals( "<p>As Emerson said in his essay <cite>Self-Reliance</cite>:</p><blockquote>&quot;A foolish consistency is the hobgoblin of little minds.&quot;</blockquote>", xhtml.body );
	
	}
	
	public function testBuild() {
		var xhtml = new xmpp.XHTML( "test" );
		assertEquals( '<html xmlns="http://jabber.org/protocol/xhtml-im"><body xmlns="http://www.w3.org/1999/xhtml">test</body></html>', xhtml.toXml().toString() );
		assertEquals( 'test', xhtml.body );
		var m = new xmpp.Message();
		xmpp.XHTML.attach( m, "<strong>mybody</strong>" );
		var body = xmpp.XHTML.fromMessage( m );
		assertEquals( "<strong>mybody</strong>", body );
	}
	
}
