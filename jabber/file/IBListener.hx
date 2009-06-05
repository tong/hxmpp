package jabber.file;

/**
	Listens for incoming in-band file transfers.
*/
class IBListener {
	
	/** */
	public var onRequest : IBReciever->Void;
	public var stream(default,null) : jabber.Stream;
	
	public function new( stream : jabber.Stream ) {
		this.stream = stream;
		// collect requests
		var f : xmpp.PacketFilter = new xmpp.filter.IQFilter( xmpp.InBandByteStream.XMLNS, "open", xmpp.IQType.set );
		stream.addCollector( new jabber.stream.PacketCollector( [f], handleRequest, true ) );
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		var r = new IBReciever( stream );
		if( r.handleRequest( iq ) ) {
			onRequest( r );
		}
	}
	
}
