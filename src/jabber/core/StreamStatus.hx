package jabber.core;


enum StreamStatus {
	
	/**
		No XMPP data has been sent over the connection so far.
	*/
	closed;
	
	/**
		Stream opening sent, but no response so far.
	*/
	pending; // TODO pending( status : String );
	
	/**
		XMPP stream is open and ready to exchange packets.
	*/
	open;
	
}
