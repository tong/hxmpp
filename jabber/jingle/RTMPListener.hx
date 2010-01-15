package jabber.jingle;

import jabber.stream.PacketCollector;

/**
	Listens for incoming jingle-RTMP session requests.
*/
class RTMPListener {
	
	public var stream(default,null) : jabber.Stream;
	public var handler(default,setHandler) : RTMPResponder->Void;
	
	var c : PacketCollector;
	
	public function new( stream : jabber.Stream, handler : RTMPResponder->Void ) {
		if( !stream.features.add( xmpp.jingle.RTMP.XMLNS ) )
			throw "RTMP listener already added";
		this.stream = stream;
		this.handler = handler;
	}
	
	function setHandler( h : RTMPResponder->Void ) : RTMPResponder->Void {
		if( c != null ) {
			stream.removeCollector( c );
			c = null;
		}
		if( h != null )
			c = stream.collect( [cast new xmpp.filter.IQFilter( xmpp.Jingle.XMLNS, "jingle", xmpp.IQType.set ),
								 cast new xmpp.filter.JingleFilter( xmpp.jingle.RTMP.XMLNS ) ], handleRequest, true );
		return handler = h;
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		if( handler == null )
			return;
		var r = new jabber.jingle.RTMPResponder( stream );
		if( r.handleRequest( iq ) )
			handler( r );
	}
	
}
