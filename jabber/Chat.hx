package jabber;

import jabber.core.PacketCollector;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketFromFilter;


/**
	Represents a chat conversation between two jabber clients.
*/
class Chat {
	
	public dynamic function onMessage( c : Chat ) : Void;
	
	public var stream(default,null) : Stream;
	public var peer(default,null) : String;
	public var threadID(default,setThreadID) : String;
	public var lastMessage(default,null) : xmpp.Message;
	
	var c : PacketCollector;
	var m : xmpp.Message;
	
	// TODO myJid? needed ?
	public function new( stream : Stream, myJid : String, peer : String,
					 	 ?threadID : String ) {
		
		m = new xmpp.Message( peer, null, null, xmpp.MessageType.chat, threadID, myJid );
		
		this.stream = stream;
		this.peer = peer;
		this.threadID = threadID;
		
		var mf : xmpp.PacketFilter = new xmpp.filter.MessageFilter( xmpp.MessageType.chat );
		var ff : xmpp.PacketFilter = new xmpp.filter.PacketFromContainsFilter( peer );
		c = new PacketCollector( [ mf, ff ], handleMessage, true );
		stream.addCollector( c );
	}
	
	
	function setThreadID( id : String ) : String {
		threadID = m.thread = id;
		return id;
	}
	
	
	/**
		Sends a chat message to the peer.
	*/
	public function speak( t : String ) : xmpp.Message {
		m.body = t;
		return stream.sendPacket( m );
	}
	
	/**
		Removes the collector from this stream.
	*/
	public function destroy() {
		stream.removeCollector( c );
	}
	
	/**
		Handles incoming message.
	*/	
	public function handleMessage( m : xmpp.Message ) {
		#if JABBER_DEBUG
		if( m.type != xmpp.MessageType.chat ) {
			trace( "Chats can only handle chat-type messages" );
			return;
		}
		#end
		lastMessage = m;
		onMessage( this );
	}
	
}
