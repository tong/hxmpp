package jabber;


enum StreamStatus {
	
	/**
		No XMPP data has been sent over the connection so far.
	*/
	closed;
	
	/**
		Stream.connection is connected but no xmpp data exchange happend so far.
	*/
	connected;
	
	/**
		Stream opening sent, but no response so far.
	*/
	pending( status : String );
	
	/**
		XMPP stream is open and ready to exchange xmpp data.
	*/
	open;
}
