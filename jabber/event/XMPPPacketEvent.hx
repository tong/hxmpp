package jabber.event;


/**
	Abstract base for xmpp packet events.
*/
class XMPPPacketEvent<T:jabber.Stream> extends StreamEvent<T> {
	
	public var from(default,null) : String;
	public var to(default,null) : String;
	public var id(default,null) : String;
	
	function new( s : T, p : xmpp.Packet ) {
		super( s );
		from = p.from;
		to = p.to;
		id = p.id;
	}
	
}
