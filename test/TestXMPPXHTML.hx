
class TestXMPPXHTML extends haxe.unit.TestCase   {
	
	public function testParse() {
		
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
		var xhtml : xmpp.XHTML = null;
		for( p in m.properties ) {
			if( p.nodeName == "html" && p.get( "xmlns" ) == xmpp.XHTML.XMLNS ) {
				xhtml = xmpp.XHTML.parse( p );
				break;
			}
		}
		assertEquals( "<strong>envy</strong>!", xhtml.body );
		
		x = Xml.parse(
"<message>
  <body>As Emerson said in his essay Self-Reliance:&quot;A foolish consistency is the hobgoblin of little minds.&quot;</body>
  <html xmlns='http://jabber.org/protocol/xhtml-im'>
    <body xmlns='http://www.w3.org/1999/xhtml'><p>As Emerson said in his essay <cite>Self-Reliance</cite>:</p><blockquote>&quot;A foolish consistency is the hobgoblin of little minds.&quot;</blockquote></body>
  </html>
</message>" ).firstElement();
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
	
	//public function testCreation() {
		//TODO
	//}
	
}
