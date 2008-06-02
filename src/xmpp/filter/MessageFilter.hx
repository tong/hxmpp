package xmpp.filter;

import xmpp.PacketType;
import xmpp.Message;



/** 
	Filters message packets, optional with given xmpp.MessageType.
*/
class MessageFilter implements IPacketFilter {
		
	public var type : MessageType;
	
	public function new( ?messageType : MessageType ) {
		this.type = if( messageType == null ) MessageType.normal else messageType;
	}
	
	public function accept( packet : xmpp.Packet ) {
		if( packet._type != PacketType.message ) return false;
		if( type != null ) return this.type == untyped packet.type;
		return true;
	}
}
