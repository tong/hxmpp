package xmpp.filter;


/**
	Filters packets with matching id attribute.
*/
class PacketIDFilter implements IPacketFilter {
	
	public var id : String;
	
	public function new( id : String ) {
		this.id = id;
	}
	
	public function accept( packet : xmpp.Packet ) : Bool {
		return packet.id == id;
	}
	
}
