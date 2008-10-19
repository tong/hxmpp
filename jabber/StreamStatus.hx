package jabber;


enum StreamStatus {
	
	/**
		Stream is inactive.
	*/
	closed;
	
	/**
		Stream opening sent, but no response so far.
	*/
	pending;
	//pending( ?info : String );
	
	/**
		XMPP stream is open and ready to exchange packets.
	*/
	open;
	//open( info : String );
	//open( ?i : T );
}
