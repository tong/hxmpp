
class TestXMPPXHTML extends haxe.unit.TestCase   {
	
	public function testParsing() {
		
		var xml = Xml.parse(
"<message>
  <body>hi!</body>
  <html xmlns='http://jabber.org/protocol/xhtml-im'>
    <body xmlns='http://www.w3.org/1999/xhtml'>
      <p style='font-weight:bold'>hi!</p>
    </body>
  </html>
</message>" ).firstElement();
		var m = xmpp.Message.parse( xml );
		var xhtml = xmpp.XHTML.fromMessage( m );
		assertEquals( "body", xhtml.nodeName );
		assertEquals( "http://www.w3.org/1999/xhtml", xhtml.get( "xmlns" ) );
		var p = xhtml.firstElement();
		assertEquals( "p", p.nodeName );
		
		
		xml = Xml.parse( "<message><body>hi!</body></message>" ).firstElement();
		m = xmpp.Message.parse( xml );
		xhtml = xmpp.XHTML.fromMessage( m );
		assertEquals( null, xhtml );
	}
	
	//public function testCreation() {
		//TODO
	//}
	
}
