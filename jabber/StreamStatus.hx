package jabber;


enum StreamStatus {
	
	/**
		XMPP stream is inactive.
	*/
	closed;
	
	/**
		Request to open XMPP stream sent but no response so far.
	*/
	pending; //pending( ?info : String );
	
	/**
		XMPP stream is open and ready to exchange data.
	*/
	open; //open( ?info : String );
	
}
