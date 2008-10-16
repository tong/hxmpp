package xmpp.filter;


/**
	Filters (custom) packets with given nodename.
*/
class PacketNameFilter {
	
	public var name : String;
	
	public function new( name  : String ) {
		this.name = name;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		return name == p.toXml().nodeName;
	}
	
}
