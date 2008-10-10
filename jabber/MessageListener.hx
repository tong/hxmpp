package jabber;

import jabber.core.PacketCollector;
import xmpp.Message;
import xmpp.filter.MessageFilter;


/**
	Shortcut utility to simplify listening for incoming (normal type) message packets.
*/
class MessageListener {
	
	static var streamJids = new List<String>;
	
	/**
		Activates/Deactivates collecting message packets.
	*/
	public var listen(default,setListening) : Bool;
	public var stream(default,null) : Stream;
	
	var collector : PacketCollector;
	
	
	/**
		Create a new Message listeners, throws an error if a listeners got already added to the stream.
	*/
	public function new( stream : Stream, ?listen : Bool = true ) {
		
		for( jid in streamJids ) {
			if( jid == stream.jid.bar ) {
				return null;
			}
		}
		
		this.stream = stream;
		
		collector = new PacketCollector( [cast new MessageFilter()], onMessageTest, true );
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
