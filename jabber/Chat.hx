package jabber;

import jabber.core.PacketCollector;
import jabber.core.StreamBase;
import xmpp.filter.PacketFilter;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketFromFilter;


/**
	Represents a chat conversation between two jabber clients.
*/
class Chat {
	
	public dynamic function onMessage( chat : Chat ) {}
	
	public var stream(default,null) : StreamBase;
	public var peer(default,null) : String;
	public var threadID(default,setThreadID) : String;
	public var lastMessage(default,null) : xmpp.Message;
	
	var message : xmpp.Message;
	var collector : PacketCollector;
	
	
	public function new( stream : StreamBase, myJid : String, peer : String, ?threadID : String ) {
		
		message = new xmpp.Message( xmpp.MessageType.chat, peer, null, null, threadID, myJid );

		this.stream = stream;
		this.peer = peer;
		this.threadID = threadID;
		
		var mf : PacketFilter = new xmpp.filter.MessageFilter( xmpp.MessageType.chat );
		var ff : PacketFilter = new xmpp.filter.PacketFromFilter( peer );
		collector = new PacketCollector( [ mf, ff ], handleMessage, true );
		stream.collectors.add( collector );
	}
	
	
	function setThreadID( id : String ) : String {
		threadID = message.thread = id;
		return id;
	}
	
	
	/**
		Sends a chat message to the peer.
	*/
	public function speak( t : String ) : xmpp.Message {
		message.body = t;
		return stream.sendPacket( message );
	}
	
	/**
	*/
	public function destroy() {
		stream.collectors.remove( collector );
	}
	
	/**
		Handles incoming message.
	*/	
	public function handleMessage( m : xmpp.Message ) {
		lastMessage = m;
		onMessage( this );
	}
	
}
