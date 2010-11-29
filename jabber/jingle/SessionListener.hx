package jabber.jingle;

import jabber.jingle.io.Transport;
import jabber.stream.PacketCollector;

class SessionListener<T:Transport,R:SessionResponder<T>> {
	
	public var stream(default,null) : jabber.Stream;
	public var handler(default,setHandler) : R->Void;
	
	var xmlns : String;
	var c : PacketCollector;
	
	function new( stream : jabber.Stream, handler : R->Void, xmlns : String ) {
		if( !stream.features.add( xmlns ) )
			throw new jabber.error.Error( "RTMP listener already added" );
		this.stream = stream;
		this.handler = handler;
		this.xmlns = xmlns;
	}
	
	function setHandler( h : R->Void ) : R->Void {
		if( h == null ) {
			if( c != null ) {
				stream.removeCollector( c );
				c = null;
			}
		} else if( c == null )
			c = stream.collect( [cast new xmpp.filter.JingleFilter( xmlns )], handleRequest, true );
		return handler = h;
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		if( handler == null )
			return;
		var r = createResponder();
		if( r.handleRequest( iq ) ) {
			handler( r );
		}
	}
	
	// override me
	function createResponder() : R {
		return throw new jabber.error.AbstractError();
	}
	
}
