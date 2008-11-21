package xmpp.filter;


/**
	Filters xmpp packets where the from attribute contains the given string.
*/
class PacketFromContainsFilter {
	
	public var contained : String;
	
	public function new( contained : String ) {
		this.contained = contained;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		if( p.from == null ) return false;
		try {
			return new EReg( contained, "" ).match( p.from );
		} catch( e : Dynamic ) {
			return false;
		}
	}
	
	#if JABBER_DEBUG
	
	public function toString() : String {
		return "xmpp.PacketFromContainsFilter("+contained+")";
	}
	
	#end
	
}
