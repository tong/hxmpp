package jabber;

import jabber.core.PacketCollector;


/**
*/
class MessageListener {

	public dynamic function onMessage( m : xmpp.Message ) : Void;
	
	/**
		Activates/Deactivates message packet collecting.
	*/
	public var listen(default,setListening) : Bool;
	public var stream(default,null) : Stream;
	
	var c : PacketCollector;
	
	
	public function new( stream : Stream,
						 ?onMessage : xmpp.Message->Void, ?listen : Bool = true ) {
		
		c = new PacketCollector( [cast new xmpp.filter.MessageFilter()], messageHandler, true );
		
		this.stream = stream;
		if( onMessage != null ) this.onMessage = onMessage;
		setListening( listen );
	}

	
	function setListening( v : Bool ) : Bool {
		if( v ) stream.addCollector( c ) else stream.removeCollector( c );
		return listen = v;
	}
	
	
	// override me if you want
	function messageHandler( m : xmpp.Message ) {
		this.onMessage( m );
	}

}
