package jabber.event;


class IQResult<T:jabber.Stream,Data> extends XMPPPacketEvent<T> {
	
	public var data(default,null) : Data;
	
	public function new( s : T, iq : xmpp.IQ, ?data : Data ) {
		super( s, iq );
		this.data = data;
	}
	
}
