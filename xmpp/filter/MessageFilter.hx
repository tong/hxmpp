package xmpp.filter;

import xmpp.PacketType;
import xmpp.MessageType;


/** 
	Filters message packets, optional with given xmpp.MessageType.
*/
class MessageFilter {
		
	public var type : MessageType;
	
	public function new( ?messageType : MessageType ) {
		this.type = messageType;
	}
	
	public function accept( p : xmpp.Packet ) {
		if( p._type != PacketType.message ) return false;
		if( this.type != null ) return this.type == untyped p.type;
		return true;
	}
	
}
