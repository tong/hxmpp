package jabber;

import jabber.core.PacketCollector;


/**
	Utility for listening to incoming messages.
*/
class MessageListener {

	public dynamic function onMessage( m : xmpp.Message ) {}
	
	/**
		Activates/Deactivates collecting message packets.
	*/
	public var listen(default,setListening) : Bool;
	public var stream(default,setStream) : Stream;
	
	var collector : PacketCollector;
	
	
	public function new( stream : Stream, ?listen : Bool = true ) {
		
		setStream( stream );
		
		collector = new PacketCollector( [cast new xmpp.filter.MessageFilter()], messageHandler, true );
		setListening( listen );
	}
	
	
	function setStream( s : Stream ) : Stream {
		if( s == stream ) return s;
		var wasListening = listen;
		if( listen ) setListening( false );
		Reflect.setField( this, "stream", s );
		if( wasListening ) setListening( true );
		return s;
	}
	
	function setListening( v : Bool ) : Bool {
		if( v ) stream.collectors.add( collector );
		else stream.collectors.remove( collector );
		return listen = v;
	}
	
	// keep for possible override
	function messageHandler( m : xmpp.Message ) {
		this.onMessage( m );
	}
	
}
