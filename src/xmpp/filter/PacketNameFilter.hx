package xmpp.filter;


/**
	Filters (custom) packets with given xml nodename.
*/
class PacketNameFilter implements IPacketFilter {
	
	public var name : String;
	
	public function new( name  : String ) {
		this.name = name;
	}
	
	public function accept( packet  : xmpp.Packet ) : Bool {
		return name == packet.toXml().nodeName; //TODO xmpp.Packet.name
	}
}
