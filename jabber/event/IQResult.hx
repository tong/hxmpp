package jabber.event;

import jabber.core.StreamBase;


class IQResult<T> extends XMPPPacketEvent {
	
	public var data(default,null) : T;
	
	public function new( s : StreamBase, iq : xmpp.IQ, ?data : T ) {
		super( s, iq );
		this.data = data;
	}
	
}
