package jabber.client;

import xmpp.Message;
import xmpp.filter.MessageFilter;
import jabber.PacketCollector;


/**
	Listens for incoming (normal type) message packets.
*/
class MessageListener extends event.Dispatcher<Message> {
	
	public function new( stream : Stream ) {
		super();
		stream.collectors.add( new PacketCollector( [ new MessageFilter( MessageType.normal ) ], handleMessage, true ) );
	}
	
	function handleMessage( m : Message ) {
		dispatchEvent( m );
	}
}
