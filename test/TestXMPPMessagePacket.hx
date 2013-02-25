
import xmpp.Message;
import xmpp.MessageType;

class TestXMPPMessagePacket extends TestCase {
	
	public function testBuild() {
		var m = new xmpp.Message();
		eq( '<message type="chat"/>', m.toString() );
		m.type = xmpp.MessageType.chat;
		eq( m.toString(), '<message type="chat"/>' );
		m.type = xmpp.MessageType.groupchat;
		eq( m.toString(), '<message type="groupchat"/>' );
		m.type = xmpp.MessageType.headline;
		eq( m.toString(), '<message type="headline"/>' );
		m.type = xmpp.MessageType.error;
		eq( m.toString(), '<message type="error"/>' );
		m.type = null;
		eq( m.toString(), '<message/>' );
		m.type = null;
		m.body = "my message";
		eq( m.toString(), '<message><body>my message</body></message>' );
		m.properties.push( Xml.parse( '<custom xmlns="http://namespace.disktree.net">mycustompacket</custom>' ).firstElement() );
		eq( 1, m.properties.length );
		eq( '<custom xmlns="http://namespace.disktree.net">mycustompacket</custom>', m.properties[0].toString() );
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
		eq( chat, m.type );
		eq( 'green with envy!', m.body );
		eq( 1, m.properties.length );
		eq( "html", m.properties[0].nodeName );
	}
	
}
