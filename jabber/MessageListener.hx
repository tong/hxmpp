package jabber;

import jabber.core.PacketCollector;
import xmpp.Message;


/**
	Shortcut utility to simplify listening for incoming (normal type) message packets.
*/
class MessageListener {
	
	/**
		Activates/Deactivates collecting message packets.
	*/
	public var listen(default,setListening) : Bool;
	public var stream(default,null) : Stream;
	
	var collector : PacketCollector;
	
	
	public function new( stream : Stream, ?listen : Bool = true ) {
		
		this.stream = stream;
		
		collector = new PacketCollector( [cast new xmpp.filter.MessageFilter()], onMessageTest, true );
		setListening( listen );
	}
	

	public dynamic function onMessage( m : xmpp.Message ) : Void {}

	
	function setListening( v : Bool ) : Bool {
		if( v ) stream.collectors.add( collector );
		else stream.collectors.remove( collector );
		return listen = v;
	}
	
	function onMessageTest( m : xmpp.Message ) {
		onMessage( m );
	}
	
}
