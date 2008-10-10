package xmpp.filter;


/** 
*/
class CompositeFilter extends List<xmpp.PacketFilter> {
	
	public function new() {
		super();
	}
	
	public function accept( packet : xmpp.Packet ) {
		for( f in iterator() ) {
			if( !f.accept( packet ) ) return false;
		}
		return true;
	}
	
}
