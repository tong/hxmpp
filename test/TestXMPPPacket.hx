
import xmpp.Message;
import xmpp.Presence;
import xmpp.IQ;


class TestXMPPPacket {

	static function main() {
		
		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		haxe.Firebug.redirectTraces();
		
		var r = new haxe.unit.TestRunner();
		r.add( new TestMessagePacket() );
		r.add( new TestPresencePacket() );
		r.add( new TestIQPacket() );
		r.run();
	}
	
}


class TestMessagePacket extends haxe.unit.TestCase   {
	
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

	public function testMessageParse() {
		
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
		
		// TODO
	}
	
}


class TestPresencePacket extends haxe.unit.TestCase   {
	
	public function testPresenceCreate() {
		
		var p = new xmpp.Presence();
		
		assertEquals( p.toString(), '<presence/>' );
		p.type = "available";
		assertEquals( p.toString(), '<presence type="available"/>' );
		p.show = "dnd";
		assertEquals( p.toString(), '<presence type="available"><show>dnd</show></presence>' );
		p.status = "be right back";
		assertEquals( p.toString(), '<presence type="available"><show>dnd</show><status>be right back</status></presence>' );
		p.priority = 5;
		assertEquals( p.toString(), '<presence type="available"><show>dnd</show><status>be right back</status><priority>5</priority></presence>' );
		
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
		assertEquals( iq.toString(), '<iq type="get" id="123"/>' );
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
