
class TestXMPPIBByteStream extends haxe.unit.TestCase {
	
	public function testParse() {
		
		var x = Xml.parse( "<close xmlns='http://jabber.org/protocol/ibb' sid='i781hf64'/>" ).firstElement();
		var ib = xmpp.file.IB.parse( x );
		assertEquals( xmpp.file.IBType.close, ib.type );
		assertEquals( 'i781hf64', ib.sid );
		
		var x = Xml.parse( "<data xmlns='http://jabber.org/protocol/ibb' sassertEquals='0' sid='i781hf64'>qANQR1DBwU4DX7jmYZnncmUQB/9KuKBddzQH+tZ1ZywKK0yHKnq57kWq+RFtQdCJWpdWpR0uQsuJe7+vh3NWn59/gTc5MDlX8dS9p0ovStmNcyLhxVgmqS8ZKhsblVeuIpQ0JgavABqibJolc3BKrVtVV1igKiX/N7Pi8RtY1K18toaMDhdEfhBRzO/XB0+PAQhYlRjNacGcslkhXqNjK5Va4tuOAPy2n1Q8UUrHbUd0g+xJ9Bm0G0LZXyvCWyKHkuNEHFQiLuCY6Iv0myq6iX6tjuHehZlFSh80b5BVV9tNLwNR5Eqz1klxMhoghJOA</data>" ).firstElement();
		var ib = xmpp.file.IB.parse( x );
		assertEquals( 'qANQR1DBwU4DX7jmYZnncmUQB/9KuKBddzQH+tZ1ZywKK0yHKnq57kWq+RFtQdCJWpdWpR0uQsuJe7+vh3NWn59/gTc5MDlX8dS9p0ovStmNcyLhxVgmqS8ZKhsblVeuIpQ0JgavABqibJolc3BKrVtVV1igKiX/N7Pi8RtY1K18toaMDhdEfhBRzO/XB0+PAQhYlRjNacGcslkhXqNjK5Va4tuOAPy2n1Q8UUrHbUd0g+xJ9Bm0G0LZXyvCWyKHkuNEHFQiLuCY6Iv0myq6iX6tjuHehZlFSh80b5BVV9tNLwNR5Eqz1klxMhoghJOA', ib.data );
		assertEquals( 0, ib.seq );
		assertEquals( 'i781hf64', ib.sid );
	}
	
	public function testBuild() {
		var ib = new xmpp.file.IB( xmpp.file.IBType.open, "id123", 4096 );
		var x = ib.toXml();
		assertEquals( "open", x.nodeName );
		assertEquals( "id123", x.get( "sid" ) );
		assertEquals( "4096", x.get( "block-size" ) );
	}
	
}
