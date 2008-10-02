package xmpp.filter;


/**
	Filters xmpp packets with matching from attribute.
*/
class PacketFromFilter {
	
	public var from : String;
	
	public function new( from : String ) {
		this.from = from;
	}
	
	public function accept( packet : xmpp.Packet ) : Bool {
		return packet.from == from;
	}
	
}
