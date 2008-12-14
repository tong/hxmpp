
import xmpp.Message;
import xmpp.MessageType;
import xmpp.Presence;
import xmpp.IQ;
import xmpp.IQType;


class TestXMPPPacket {}



class TestMessagePacket extends haxe.unit.TestCase   {
	
	/*
	public function testMessageCreate() {
		
		var m = new xmpp.Message();
		
		assertEquals( m.toString(), '<message type="normal"/>' );
		m.type = xmpp.MessageType.chat;
		assertEquals( m.toString(), '<message type="chat"/>' );
		m.type = xmpp.MessageType.groupchat;
		assertEquals( m.toString(), '<message type="groupchat"/>' );
		m.type = xmpp.MessageType.headline;
		assertEquals( m.toString(), '<message type="headline"/>' );
		m.type = xmpp.MessageType.error;
		assertEquals( m.toString(), '<message type="error"/>' );
		
		m.subject = "SUBJECT";
		assertEquals( m.subject, "SUBJECT" );
		
		m.body = "BODY";
		assertEquals( m.body, "BODY" );
		
		m.thread = "12345";
		assertEquals( m.thread, "12345" );
	}
	*/

	public function testMessageParse() {
		/*
		var src = Xml.parse( '
			<message type="chat" to="tong@igniterealtime.org" id="ab01a" >
				<body>abc</body>
				<active xmlns="http://jabber.org/protocol/chatstates"/>
			</message>' ).firstElement();
		
		var m = cast xmpp.Packet.parse( src );
		assertEquals( m.type, MessageType.chat );
		assertEquals( m.to, "tong@igniterealtime.org" );
		assertEquals( m.id, "ab01a" );
		assertEquals( m.body, "abc" );
		
		*/
		var src = Xml.parse( '
			<message to="hxmpp@disktree">
				<body>Wow, I&apos;m green with envy!</body>
					<html xmlns="http://jabber.org/protocol/xhtml-im">
						<body xmlns="http://www.w3.org/1999/xhtml">
							<p style="font-size:large">
								<em>Wow</em>, I&apos;m <span style="color:green">green</span>
								with <strong>envy</strong>!
							</p>
						</body>
					</html>
			</message>' ).firstElement();
		
		var m : Message = cast xmpp.Packet.parse( src );
		assertEquals( normal, m.type );
		assertEquals( 'Wow, I&apos;m green with envy!', m.body );
		assertEquals( 1, m.properties.length );
	}
	
}



class TestPresencePacket extends haxe.unit.TestCase   {
	
	public function testPresenceCreate() {
		
		var p = new xmpp.Presence();
		
		assertEquals( p.toString(), '<presence/>' );
		p.type = xmpp.PresenceType.subscribe;
		assertEquals( p.toString(), '<presence type="subscribe"/>' );
		p.show = "dnd";
		assertEquals( '<presence type="subscribe"><show>dnd</show></presence>', p.toString() );
		p.status = "be right back";
		assertEquals( '<presence type="subscribe"><show>dnd</show><status>be right back</status></presence>', p.toString() );
		p.priority = 5;
		assertEquals( '<presence type="subscribe"><show>dnd</show><status>be right back</status><priority>5</priority></presence>', p.toString() );
		
	}
	
	public function testPreseceParse() {
		
		var src = Xml.parse( '
			<presence>
				<show>away</show>
				<priority>5</priority>
				<c xmlns="http://jabber.org/protocol/caps" node="http://psi-im.org/caps" ver="0.11-dev-rev8" ext="cs ep-notify html" />
			</presence>' ).firstElement();
		
		var p = cast xmpp.Packet.parse( src );
		assertEquals( p.show, 'away' );
		assertEquals( p.priority, 5 );
		
		//..
	}
	
}



class TestIQPacket extends haxe.unit.TestCase   {
	
	public function testIQCreate() {
		var iq = new xmpp.IQ( null, "123" );
		assertEquals( iq.type, IQType.get );
		assertEquals( iq.id, "123" );
		//assertEquals( iq.toString(), '<iq type="get" id="123"/>' );
	}

	public function testIQParse() {
		
		var src = Xml.parse( '
			<iq type="get" to="jabber.spektral.at" id="ab08a" >
				<query xmlns="http://jabber.org/protocol/disco#info"/>
				</iq>' ).firstElement();
				
		var iq = cast xmpp.Packet.parse( src );
		assertEquals( iq.type, get );
		assertEquals( iq.to, 'jabber.spektral.at' );
		assertEquals( iq.id, 'ab08a' );
		assertEquals( iq.ext.toString(), '<query xmlns="http://jabber.org/protocol/disco#info"/>' );
		
		//TODO any properties
	}
	
//	public function testIQAuth() {
//	}
	
}



class TestErrorExtension extends haxe.unit.TestCase {
	
	public function testExtension() {
		var err = xmpp.Error.parse( Xml.parse( '<error type="cancel"><conflict xmlns="urn:ietf:params:xml:ns:xmpp-stanzas"/></error>' ).firstElement() );
		assertEquals( err.type, xmpp.ErrorType.cancel );
		assertEquals( err.name, "conflict" );
		assertEquals( err.text, null );
		
	}
}



class TestXMPPDate extends haxe.unit.TestCase {
	
	public function testDateFormatting() {
		
		var now = "2008-11-01";
		var formatted = xmpp.Date.format( now );
		assertEquals( now, formatted );
		
		now = "2008-11-01";
		formatted = xmpp.Date.format( now, 2 );
		assertEquals( now, formatted );
		
		now = "2008-11-01 19:06:02";
		formatted = xmpp.Date.format( now );
		assertEquals( "2008-11-01T19:06:02Z", formatted );
		
		now = "2008-11-01 19:06:02";
		formatted = xmpp.Date.format( now, 2 );
		assertEquals( "2008-11-01T19:06:02-02:00", formatted );
	}
}



class TestXMPPCompression extends haxe.unit.TestCase {
		
	public function testPacket() {
		
		var p = xmpp.Compression.createPacket( ["zlib"] );
		assertEquals( '<compress xmlns="http://jabber.org/protocol/compress"><method>zlib</method></compress>', p.toString() );

		var x = Xml.parse( '<compression xmlns="http://jabber.org/features/compress"><method>zlib</method></compression>' ).firstElement();
		var methods = xmpp.Compression.parseMethods( x );
		assertEquals( 1, methods.length );
		assertEquals( "zlib", methods[0] );
	}
		
}
