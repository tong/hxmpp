package xmpp.filter;


/**
	//Filters (custom) packets with given nodename.
*/
class PacketNameFilter {
	
	public var regx : EReg;
	
	public function new( regx : EReg ) {
		this.regx = regx;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		return regx.match( p.toXml().nodeName );
	}
	
}
