package xmpp.filter;


/**
	Filters (custom) packets with given nodename.
*/
class PacketNameFilter {
	
	// TODO regexp
	//public var exp : EReg;
	public var name : String;
	
	public function new( name : String ) {
		this.name = name;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		//TODO return exp.match( p.toXml().nodeName );
		return ( name == p.toXml().nodeName );
	}
	
}
