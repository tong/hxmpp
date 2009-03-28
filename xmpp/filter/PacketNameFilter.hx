package xmpp.filter;

/**
	Filters (custom) XMPP packets with given nodename EReg.
*/
class PacketNameFilter {
	
	public var ereg : EReg; //TODO string
	
	public function new( ereg : EReg ) {
		this.ereg = ereg;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		return ereg.match( p.toXml().nodeName );
	}
	
}
