package xmpp.filter;


/**
	Returns true if any of the filters accepts the xmpp packet.
*/
class PacketOrFilter extends List<xmpp.PacketFilter> {
	
	public function new( ?filters : Iterable ) {
		super();
		if( filters != null ) {
			for( f in filters ) add( f );
		}
	}
	
	public function accept( packet : xmpp.Packet ) : Bool {
		for( f in iterator() ) {
			if( f.accept( packet ) ) return true;
		}
		return false;
	}
	
}
