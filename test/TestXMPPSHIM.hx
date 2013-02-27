
class TestXMPPSHIM extends haxe.unit.TestCase {

	public function testParse() {
	
		var x = Xml.parse( "<headers xmlns='http://jabber.org/protocol/shim'>
    <header name='In-Reply-To'>123456789@capulet.com</header>
	<header name='Keywords'>shakespeare,&lt;xmpp/&gt;</header>
</headers>" ).firstElement();

		var shim = xmpp.SHIM.parse( x );
		
		assertEquals( 2, shim.headers.length );
		var h1 = shim.headers[0];
		assertEquals( 'In-Reply-To', h1.name );
		assertEquals( '123456789@capulet.com', h1.value );
		var h2 = shim.headers[1];
		assertEquals( 'Keywords', h2.name );
		
		//TODO
		/*
		//trace( h2.value );
		assertEquals( 'shakespeare,&lt;xmpp/&gt;', h2.value ); // TODO PHP ERROR!!
		*/
		
		
		//-------------------------------------------------------------------------------------------------
		
		/* 
		var x = Xml.parse( "<header name='Keywords'>shakespeare,&lt;xmpp/&gt;</header>" ).firstElement();
		trace( x.firstChild().nodeValue );
		//TestXMPPSHIM.hx:27: shakespeare, //// php
		//TestXMPPSHIM.hx:27: shakespeare,&lt;xmpp/&gt; //// js
		//TestXMPPSHIM.hx:27: shakespeare,&lt;xmpp/&gt; //// neko
		*/
		
		/* 
		//var x = Xml.parse( "<node>shakespeare,&lt;xmpp/&gt;</node>" ).firstElement();
		var x = Xml.parse( "<node>shakespeare,&lt;any/&gt;</node>" ).firstElement();
		trace( x.firstChild().nodeValue );
		//TestXMPPSHIM.hx:34: shakespeare,&lt;xmpp/&gt; ////js
		//TestXMPPSHIM.hx:34: shakespeare,&lt;xmpp/&gt; ////neko
		//TestXMPPSHIM.hx:34: shakespeare, ////php
		
		assertTrue( true );
		*/
		
	}
	
	// TODO test packet create
	
}
