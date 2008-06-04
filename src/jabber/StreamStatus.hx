package jabber;


enum StreamStatus {
	
	/**
		No XMPP data has been sent over the connection so far.
	*/
	closed;
	
	/**
		Stream opening sent, but no response so far.
	*/
	pending;
	//pending( status : String );
	
	/**
		XMPP stream is open and ready to exchabge packets.
	*/
	open;
}
