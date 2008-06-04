package jabber.util;

import xmpp.filter.PacketIDFilter;


class PacketIDCollector extends jabber.PacketCollector {
	
	public function new( id : String, handler : xmpp.IQ->Void ) {
		super( [new PacketIDFilter( id )], handler, false, true );
	}
}
