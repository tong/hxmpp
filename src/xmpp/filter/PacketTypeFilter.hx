package xmpp.filter;



/**
	Filters packets with matching xmpp.PacketType.
*/
class PacketTypeFilter implements IPacketFilter {
	
	public var type : xmpp.PacketType;
	
	public function new( type  : xmpp.PacketType ) {
		this.type = type;
	}
	
	public function accept( packet : xmpp.Packet ) : Bool {
		return packet._type == type;
	}
}
