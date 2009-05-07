package xmpp.filter;

/**
*/
class PacketToContainsFilter {
	
	public var contains(default,setContains) : String;
	
	var ereg : EReg;
	
	public function new( contains : String ) {
		setContains( contains );
	}
	
	function setContains( t : String ) : String {
		ereg = new EReg( t, "" );
		return this.contains = t;
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		return ( p.to == null ) ? false : ereg.match( p.to );
	}
	
}
