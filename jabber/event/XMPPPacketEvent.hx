package jabber.event;

import jabber.core.StreamBase;


/**
*/
class XMPPPacketEvent extends StreamEvent {
	
	public var from : String;
	public var to : String;
	public var id : String;
	
	public function new( s : StreamBase, p : xmpp.Packet ) {
		super( s );
		from = p.from;
		to = p.to;
		id = p.id;
	}
	
}
