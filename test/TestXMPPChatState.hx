
class TestXMPPChatState extends haxe.unit.TestCase {
	
	public function testParsing() {
		
		var m = xmpp.Message.parse( Xml.parse( "
		<message from='bernardo@shakespeare.lit/pda' to='francisco@shakespeare.lit' type='chat'>
			<body>Who's there?</body>
		</message>" ).firstElement() );
		assertEquals( null, xmpp.ChatStateNotification.get( m ) );

		m = xmpp.Message.parse( Xml.parse( "
		<message from='bernardo@shakespeare.lit/pda' to='francisco@shakespeare.lit' type='chat'>
			<body>Who's there?</body>
			<active xmlns='http://jabber.org/protocol/chatstates'/>
		</message>" ).firstElement() );
		assertEquals( xmpp.ChatState.active, xmpp.ChatStateNotification.get( m ) );
		
		m = xmpp.Message.parse( Xml.parse( "
		<message from='bernardo@shakespeare.lit/pda' to='francisco@shakespeare.lit' type='chat'>
			<body>Who's there?</body>
			<composing xmlns='http://jabber.org/protocol/chatstates'/>
		</message>" ).firstElement() );
		assertEquals( xmpp.ChatState.composing, xmpp.ChatStateNotification.get( m ) );
		
		m = xmpp.Message.parse( Xml.parse( "
		<message from='bernardo@shakespeare.lit/pda' to='francisco@shakespeare.lit' type='chat'>
			<body>Who's there?</body>
		</message>" ).firstElement() );
		xmpp.ChatStateNotification.set( m, xmpp.ChatState.composing );
		assertEquals( xmpp.ChatState.composing, xmpp.ChatStateNotification.get( m ) );
	}
	
}
