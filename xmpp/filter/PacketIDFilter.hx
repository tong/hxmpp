package xmpp.filter;


/**
	Filters xmpp packets with matching id attribute.
*/
class PacketIDFilter {
	
	public var id : String;
	
	public function new( id : String ) {
		this.id = id;
	}
	
	public function accept( packet : xmpp.Packet ) : Bool {
		return packet.id == id;
	}
	
}
