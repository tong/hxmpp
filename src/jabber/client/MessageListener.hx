package jabber.client;

import jabber.core.PacketCollector;
import xmpp.Message;
import xmpp.filter.MessageFilter;


/**
	Listens for incoming (normal type) message packets.
*/
class MessageListener extends event.Dispatcher<Message> {
	
	/**
		Activate/Deactivates collecting.
	*/
	public var listening(default,setListening) : Bool;
	
	var collector : PacketCollector;
	var stream : Stream;
	
	
	public function new( stream : Stream, ?listen : Bool = true ) {
		
		super();
		this.stream = stream;
		
		collector = new PacketCollector( [new MessageFilter( MessageType.normal )], handleMessage, true );
		setListening( listen );
	}
	
	
	function setListening( v : Bool ) : Bool {
		if( v ) stream.collectors.add( collector );
		else stream.collectors.remove( collector );
		return listening = v;
	}
	
	
	function handleMessage( m : xmpp.Message ) {
		dispatchEvent( m );
	}
	
}
