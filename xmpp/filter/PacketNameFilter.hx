package xmpp.filter;

/**
	Filters (just) custom XMPP packets with given nodename EReg.
*/
class PacketNameFilter {
	
	public var reg : EReg;
	
	public function new( reg : EReg ) {
		this.reg = reg;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		/* HMMMM ? TODO
		return switch( p._type ) {
		case custom : reg.match( p.toXml().nodeName );
		default : false;
		}
		*/
		return reg.match( p.toXml().nodeName );
	}
	
}
