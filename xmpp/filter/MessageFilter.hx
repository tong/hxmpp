package xmpp.filter;


/** 
	Filters message packets, optional with given xmpp.MessageType.
*/
class MessageFilter {
		
	public var type : xmpp.MessageType;
	
	public function new( ?type : xmpp.MessageType ) {
		this.type = type;
	}
	
	public function accept( p : xmpp.Packet ) {
		if( p._type != xmpp.PacketType.message ) return false;
		if( this.type == null ) return true;
		return Type.enumConstructor( this.type ) == Type.enumConstructor( cast( p, xmpp.Message ).type );
	}
	
}
