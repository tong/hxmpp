package jabber;

import jabber.core.StreamBase;
import jabber.core.PacketCollector;


/**
	Shortcut utility to simplify listening for incoming (normal type) messages.
*/
class MessageListener {

	public dynamic function onMessage( m : xmpp.Message ) {}
	
	/**
		Activates/Deactivates collecting message packets.
	*/
	public var listen(default,setListening) : Bool;
	public var stream(default,setStream) : StreamBase;
	
	var collector : PacketCollector;
	
	
	public function new( stream : StreamBase, ?listen : Bool = true ) {
		
		setStream( stream );
		
		collector = new PacketCollector( [untyped new xmpp.filter.MessageFilter()], messageHandler, true );
		setListening( listen );
	}
	
	
	function setStream( s : StreamBase ) : StreamBase {
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
		onMessage( m );
	}
	
}
