package jabber.event;

//TODO IQResponse
class IQResult<T:jabber.Stream,P> extends XMPPPacketEvent<T> {
	
	public var packet(default,null) : P;
	
	public function new( s : T, iq : xmpp.IQ, ?packet : P ) {
		super( s, iq );
		this.packet = packet;
	}
	
}
