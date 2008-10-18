package xmpp.filter;


/**
	Returns true if ANY of the filters accepts the packet.
*/
class PacketOrFilter extends List<PacketFilter> {
	
	public function new( ?filters : Iterable<PacketFilter> ) {
		super();
		if( filters != null ) {
			for( f in filters ) add( f );
		}
	}
	
	public function accept( p : xmpp.Packet ) : Bool {
		for( f in iterator() ) {
			if( f.accept( p ) ) return true;
		}
		return false;
	}
	
}
