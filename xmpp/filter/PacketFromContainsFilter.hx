package xmpp.filter;


/**
	Filters xmpp packets where the from attribute contains the given string.
*/
class PacketFromContainsFilter {
	
	public var contained : String;
	
	public function new( contained : String ) {
		this.contained = contained;
	}
	
	public function accept( packet : xmpp.Packet ) : Bool {
		if( packet.from == null ) return false;
		return new EReg( contained, "" ).match( packet.from );
	}
	
	#if JABBER_DEBUG
	public function toString() : String {
		return "PacketFromContainsFilter("+contained+")";
	}
	#end
	
}
