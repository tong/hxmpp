package xmpp.filter;

import xmpp.PacketType;
import xmpp.Message;


/** 
	Filters message packets, optional with given xmpp.MessageType.
*/
class MessageFilter {
		
	public var type : MessageType;
	
	public function new( ?messageType : MessageType ) {
		this.type = messageType;
	}
	
	public function accept( packet : xmpp.Packet ) {
		if( packet._type != PacketType.message ) return false;
		if( this.type != null ) return this.type == untyped packet.type;
		return true;
	}
	
}
