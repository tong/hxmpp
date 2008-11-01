package jabber.event;


/**
*/
class XMPPPacketEvent<T:jabber.Stream> extends StreamEvent<T> {
	
	public var from : String;
	public var to : String;
	public var id : String;
	
	public function new( s : T, p : xmpp.Packet ) {
		super( s );
		from = p.from;
		to = p.to;
		id = p.id;
	}
	
}
