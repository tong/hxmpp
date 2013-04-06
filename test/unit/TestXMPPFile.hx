
class TestXMPPFile extends haxe.unit.TestCase {
		
	public function testParse() {
		
		/// xmpp.file.File
		
		var x = Xml.parse( "<file xmlns='http://jabber.org/protocol/si/profile/file-transfer' name='test.txt' size='1022' hash='12345abc' date='1969-07-21T02:56:15Z'>
	<desc>My description</desc>
</file>" ).firstElement();
		var f = xmpp.file.File.parse( x );
		assertEquals( "test.txt", f.name );
		assertEquals( 1022, f.size );
		assertEquals( "12345abc", f.hash );
		assertEquals( "1969-07-21T02:56:15Z", f.date );
		assertEquals( "My description", f.desc );
		assertEquals( null, f.range );
		
		x = Xml.parse( "<file xmlns='http://jabber.org/protocol/si/profile/file-transfer' name='test.txt' size='1022' hash='12345abc' date='1969-07-21T02:56:15Z'>
	<desc>My description</desc>
	<range offset='23' length='100'/>
</file>" ).firstElement();
		f = xmpp.file.File.parse( x );
		assertEquals( 23, f.range.offset );
		assertEquals( 100, f.range.length );
		
		x = Xml.parse( "<file xmlns='http://jabber.org/protocol/si/profile/file-transfer' name='test.txt' size='1022' hash='12345abc' date='1969-07-21T02:56:15Z'>
	<desc>My description</desc>
	<range/>
</file>" ).firstElement();
		f = xmpp.file.File.parse( x );
		assertTrue( f.range != null );
		
		
		/// xmpp.file.ByteStream
		
		x = Xml.parse( "<query xmlns='http://jabber.org/protocol/bytestreams' sid='vxf9n471bn46'>
	<streamhost host='24.24.24.1' jid='streamer.example.com' port='7625'/>
</query>" ).firstElement();
		var bs = xmpp.file.ByteStream.parse( x );
		assertEquals( "vxf9n471bn46", bs.sid );
		assertEquals( null, bs.mode );
		assertEquals( 1, bs.streamhosts.length );
		assertEquals( "streamer.example.com", bs.streamhosts[0].jid );
		assertEquals( "24.24.24.1", bs.streamhosts[0].host );
		assertEquals( 7625, bs.streamhosts[0].port );
		
		
		/// xmpp.file.ByteStreamHost
		
		x = Xml.parse( "<streamhost jid='rassertEqualsuester@example.com/foo' host='192.168.4.1' port='5086'/>" ).firstElement();
		var bsh = xmpp.file.ByteStreamHost.parse( x );
		assertEquals( "rassertEqualsuester@example.com/foo", bsh.jid );
		assertEquals( "192.168.4.1", bsh.host );
		assertEquals( 5086, bsh.port );
		assertEquals( null, bsh.zeroconf );
		
	}
	
}
