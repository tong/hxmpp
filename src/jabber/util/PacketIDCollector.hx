package jabber.util;

import xmpp.filter.PacketIDFilter;


class PacketIDCollector extends jabber.PacketCollector {
	
	public var id(default,setId) : String;
	var filter : PacketIDFilter;
	
	
	public function new( id : String, handler : xmpp.IQ->Void ) {
		filter = new PacketIDFilter( id );
		super( [filter], handler, false, true );
	}
	
	
	function setId( id : String ) : String {
		this.id = id;
		filter.id = id;
		return id;
	}
	
}
