package xmpp.filter;


/**
	TODO remove ??

	Filters xmpp packets with matching attribute.
*/
class PacketAttributeFilter {
	
	public var name : String; // xml attribute name
	public var value : String;
	
	public function new( name : String, value : String ) {
		this.name = name;
		this.value = value;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		return Reflect.field( p, name ) == value;
		/*
		var xml = p.toXml();
		try {
			return xml.get( name ) == value;
		} catch(  e : Dynamic ) {
			return false;
		}
		*/
	}
	
}
