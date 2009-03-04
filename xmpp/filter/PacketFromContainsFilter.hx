package xmpp.filter;


/**
	Filters XMPP packets where the from attribute contains the given string.
*/
class PacketFromContainsFilter {
	
	public var contains(default,setContains) : String;
	
	var reg : EReg;
	
	public function new( contains : String ) {
		setContains( contains );
	}
	
	function setContains( t : String ) : String {
		reg = new EReg( t, "" );
		return this.contains = t;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		if( p.from == null ) return false;
		try {
			return reg.match( p.from );
		} catch( e : Dynamic ) {
			return false;
		}
	}
	
}
