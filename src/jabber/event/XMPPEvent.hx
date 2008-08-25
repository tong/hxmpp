package jabber.event;

import jabber.core.StreamBase;



class XMPPEvent extends StreamEvent {
	
	public var packet : xmpp.Packet;
	public var incoming : Bool;
	
	
	public function new( stream : StreamBase, packet : xmpp.Packet, ?incoming : Bool = true ) {
		super( stream );
		this.packet = packet;
		this.incoming = incoming;
	}
	
}
 