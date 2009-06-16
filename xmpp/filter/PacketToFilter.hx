package xmpp.filter;

/**
	Filters XMPP packets with matching 'to' attribute.
*/
class PacketToFilter {
	
	public var jid : String;
	
	public function new( jid : String ) {
		this.jid = jid;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		return p.to == jid;
	}
	
}
