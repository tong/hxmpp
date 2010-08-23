package jabber.jingle;

import jabber.stream.PacketCollector;

/**
	Abstract base for jingle session listeners.
*/
class SessionListener<T:SessionResponder> {
	
	public var stream(default,null) : jabber.Stream;
	public var handler(default,setHandler) : T->Void;
	
	var c : PacketCollector;
	
	function new( stream : jabber.Stream, handler : T->Void ) {
		stream.features.add( getXMLNS() );
		this.stream = stream;
		this.handler = handler;
	}
	
	function setHandler( h : T->Void ) : T->Void {
		if( c != null ) {
			stream.removeCollector( c );
			c = null;
		}
		if( h != null ) {
			c = stream.collect( [cast new xmpp.filter.IQFilter( xmpp.Jingle.XMLNS, "jingle", xmpp.IQType.set ),
								 cast new xmpp.filter.JingleFilter( getXMLNS() ) ], handleRequest, true );
		}
		return handler = h;
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		if( handler == null )
			return;
		var r = createResponder();
		if( r.handleRequest( iq ) )
			handler( r );
	}
	
	// override me
	function getXMLNS() : String {
		return throw "Abstract method";
	}
	
	// override me
	function createResponder() : T {
		return throw "Abstract method";
	}
	
}
