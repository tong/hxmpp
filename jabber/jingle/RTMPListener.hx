package jabber.jingle;

/**
	Listens for incoming jingle session requests.
*/
class RTMPListener {
	
	/** Callback for RTMP session requests */
	public var handler : RTMPResponder->Void;
	public var stream(default,null) : jabber.Stream;
		
	public function new( stream : jabber.Stream, handler : RTMPResponder->Void ) {
		if( !stream.features.add( xmpp.jingle.RTMP.XMLNS ) )
			throw "RTMP session listener already added";
		stream.features.add( xmpp.Jingle.XMLNS );
		this.stream = stream;
		this.handler = handler;
		// collect RTMP session requests
		stream.addCollector( new jabber.stream.PacketCollector( [cast new xmpp.filter.JingleFilter( xmpp.jingle.RTMP.XMLNS ) ], handleRequest, true ) );
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		var r = new jabber.jingle.RTMPResponder( stream );
		if( r.handleRequest( iq ) )
			handler( r );
		else {
			trace("request not handled");
		}
	}
	
}
