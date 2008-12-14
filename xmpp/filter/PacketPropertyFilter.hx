package xmpp.filter;


/**
*/
class PacketPropertyFilter {
	
	public var xmlns : String;
	public var name : String;
	
	public function new( xmlns : String, ?name : String ) {
		this.xmlns = xmlns;
		this.name = name;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		for( p in p.properties ) {
			if( p.get( "xmlns" ) == xmlns ) {
				if( name != null ) {
					if( p.nodeName == name ) return true;
				} else {
					return true;
				}
			}
		}
		return false;
	}
	
}
