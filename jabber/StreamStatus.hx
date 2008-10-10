package jabber;

//TODO move this to xmpp.StreamStatus ?? 
enum StreamStatus {
	
	/**
		Stream is inactive.
	*/
	closed;
	
	/**
		Stream opening sent, but no response so far.
	*/
	pending;
	// TODO pending( info : String );
	
	/**
		XMPP stream is open and ready to exchange packets.
	*/
	open;
	
}
