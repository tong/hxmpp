package xmpp.filter;

/**
	Filters XMPP packets with matching to attribute.
*/
class PacketToFilter {
	
	public var to : String;
	
	public function new( to : String ) {
		this.to = to;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		return p.to == to;
	}
	
}
