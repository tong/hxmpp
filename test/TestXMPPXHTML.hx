
class TestXMPPXHTML extends TestCase {
	
	public function testParse() {
		
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
		eq( "<strong>envy</strong>!", body );
		for( p in m.properties ) {
			if( p.nodeName == "html" && p.get( "xmlns" ) == xmpp.XHTML.XMLNS ) {
				xhtml = xmpp.XHTML.parse( p );
				break;
			}
		}
		eq( "<strong>envy</strong>!", xhtml.body );
		
		var x = Xml.parse(
"<message>
  <body>As Emerson said in his essay Self-Reliance:&quot;A foolish consistency is the hobgoblin of little minds.&quot;</body>
  <html xmlns='http://jabber.org/protocol/xhtml-im'>
    <body xmlns='http://www.w3.org/1999/xhtml'><p>As Emerson said in his essay <cite>Self-Reliance</cite>:</p><blockquote>&quot;A foolish consistency is the hobgoblin of little minds.&quot;</blockquote></body>
  </html>
</message>" ).firstElement();
		var m = xmpp.Message.parse( x );
		var body = xmpp.XHTML.fromMessage( m );
		
		//TODO !!!!!!!!!!!!!!!!!!!!! fails on ccpp, neko, js
		
		eq( "<p>As Emerson said in his essay <cite>Self-Reliance</cite>:</p><blockquote>&quot;A foolish consistency is the hobgoblin of little minds.&quot;</blockquote>", body );
		for( p in m.properties ) {
			if( p.nodeName == "html" && p.get( "xmlns" ) == xmpp.XHTML.XMLNS ) {
				xhtml = xmpp.XHTML.parse( p );
				break;
			}
		}
		eq( "<p>As Emerson said in his essay <cite>Self-Reliance</cite>:</p><blockquote>&quot;A foolish consistency is the hobgoblin of little minds.&quot;</blockquote>", xhtml.body );
	}
	
	public function testBuild() {
		var xhtml = new xmpp.XHTML( "test" );
		eq( '<html xmlns="http://jabber.org/protocol/xhtml-im"><body xmlns="http://www.w3.org/1999/xhtml">test</body></html>', xhtml.toXml().toString() );
		eq( 'test', xhtml.body );
		var m = new xmpp.Message();
		xmpp.XHTML.attach( m, "<strong>mybody</strong>" );
		var body = xmpp.XHTML.fromMessage( m );
		eq( "<strong>mybody</strong>", body );
	}
	
}
