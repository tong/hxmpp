
import xmpp.Message;



class TestXMPP {
	
	static function main() {
		
		#if flash9
		flash.Lib.current.stage.scaleMode = flash.display.StageScaleMode.NO_SCALE;
		flash.Lib.current.stage.align = flash.display.StageAlign.TOP_LEFT;
		#end
		
		var r = new haxe.unit.TestRunner();
		r.add( new TestMessagePacket() );
	//	r.add( new TestPresencePacket() );
	//	r.add( new TestIQPacket() );
	//	r.add( new TestPacketFilter() );
		r.run();
	}
}


class TestMessagePacket extends haxe.unit.TestCase   {
	
	public function testMessage() {
		
		var m = new Message();
		
		assertEquals( m.toString(), '<message type="normal"/>' );
		m.type = MessageType.chat;
		assertEquals( m.toString(), '<message type="chat"/>' );
		m.type = MessageType.groupchat;
		assertEquals( m.toString(), '<message type="groupchat"/>' );
		m.type = MessageType.headline;
		assertEquals( m.toString(), '<message type="headline"/>' );
		m.type = MessageType.error;
		assertEquals( m.toString(), '<message type="error"/>' );
		
		m.subject = "SUBJECT";
		assertEquals( m.subject, "SUBJECT" );
		
		m.body = "BODY";
		assertEquals( m.body, "BODY" );
		
		m.thread = "12345";
		assertEquals( m.thread, "12345" );
		
	//	assertEquals( m.toString(), '<message type="error"><subject>SUBJECT</subject><body>BODY</body><thread>12345</thread></message>' );
		
	//	m = new Message( null, "reciever@domain.net/Resource", null, "BODY" );
	//	assertEquals( m.to, 'reciever@domain.net/Resource' );
	//	assertEquals( m.to, 'reciever@domain.net/Resource' );
		//...........
	}
}


