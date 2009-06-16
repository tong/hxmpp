package xmpp.filter;

/**
	Filters XMPP packets with matching 'from' attribute.
*/
class PacketFromFilter {
	
	public var jid : String;
	
	public function new( jid : String ) {
		this.jid = jid;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		return p.from == jid;
	}
	
}
