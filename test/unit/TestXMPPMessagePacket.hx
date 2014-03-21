
import xmpp.Message;
import xmpp.MessageType;

class TestXMPPMessagePacket extends haxe.unit.TestCase {
	
	public function testBuild() {
		var m = new xmpp.Message();
		assertEquals( '<message type="chat"/>', m.toString() );
		m.type = MessageType.chat;
		assertEquals( m.toString(), '<message type="chat"/>' );
		m.type = MessageType.groupchat;
		assertEquals( m.toString(), '<message type="groupchat"/>' );
		m.type = MessageType.headline;
		assertEquals( m.toString(), '<message type="headline"/>' );
		m.type = MessageType.error;
		assertEquals( m.toString(), '<message type="error"/>' );
		m.type = null;
		assertEquals( m.toString(), '<message/>' );
		m.type = null;
		m.body = "my message";
		assertEquals( m.toString(), '<message><body>my message</body></message>' );
		m.properties.push( Xml.parse( '<custom xmlns="http://namespace.disktree.net">mycustompacket</custom>' ).firstElement() );
		assertEquals( 1, m.properties.length );
		assertEquals( '<custom xmlns="http://namespace.disktree.net">mycustompacket</custom>', m.properties[0].toString() );
	}

	public function testParse() {
		var x = Xml.parse( '
			<message to="hxmpp@disktree">
				<body>green with envy!</body>
				<html xmlns="http://jabber.org/protocol/xhtml-im">
					<body xmlns="http://www.w3.org/1999/xhtml">
						<p style="font-size:large">
							<em>Wow</em>, I&apos;m <span style="color:green">green</span>
							with <strong>envy</strong>!
						</p>
					</body>
				</html>
			</message>' ).firstElement();
		var m : Message = cast xmpp.Packet.parse( x );
		assertEquals( MessageType.chat, m.type );
		assertEquals( "chat", Std.string( m.type ) );
		assertEquals( 'green with envy!', m.body );
		assertEquals( 1, m.properties.length );
		assertEquals( "html", m.properties[0].nodeName );
	}
	
}
