package xmpp.filter;


/**
	Filters xmpp packets with matching id attribute.
*/
class PacketAttributeFilter {
	
	public var name : String;
	public var value : String;
	
	public function new( attribute : String ) {
		this.attribute = attribute;
	}
	
	public function accept( packet : xmpp.Packet ) : Bool {
		var xml = packet.toXml();
		try {
			return xml.get( name ) == value;
		} catch(  e : Dynamic ) {
			return false;
		}
	}
	
}
