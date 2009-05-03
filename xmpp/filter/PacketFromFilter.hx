package xmpp.filter;

/**
	Filters XMPP packets with matching from attribute.
*/
class PacketFromFilter {
	
	public var from : String;
	
	public function new( from : String ) {
		this.from = from;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		return p.from == from;
	}
	
}
