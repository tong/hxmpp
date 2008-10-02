package xmpp.filter;


/**
	Filters xmpp packets where the from attribute contains the given string.
*/
class PacketFromContainsFilter {
	
	public var fromContains : String;
	
	public function new( fromContains : String ) {
		this.fromContains = fromContains;
	}
	
	public function accept( packet : xmpp.Packet ) : Bool {
		var from = packet.from;
		if( packet.from == null ) return false;
		return new EReg( fromContains, "" ).match( from );
	}
}
