package xmpp.jingle;

enum Reason {
	
	/**
		The party prefers to use an existing session with the peer rather than initiate a new session.
		The Jingle session ID of the alternative session SHOULD be provided as the XML character data of the <sid/> child.
	*/
	alternative_session;
	
	/** The party is busy and cannot accept a session. */
	busy;
	
	/** The initiator wishes to formally cancel the session initiation request. */
	cancel;
	
	/** The action is related to connectivity problems. */
	connectivity_error;
	
	/** The party wishes to formally decline the session. */
	decline;
	
	/** The session length has exceeded a pre-defined time limit (e.g., a meeting hosted at a conference service). */
	expired;
	
	/** The action is related to a non-specific application error. */
	general_error;
	
	/** The entity is going offline or is no longer available. */
	gone;
	
	/** The action is related to media processing problems. */
	media_error;
	
	/** The action is generated during the normal course of state management and does not reflect any error. */
	success;
	
	/** A request has not been answered so the sender is timing out the request. */
	timeout;
	
	/** The party supports none of the offered application types. */
	unsupported_applications;
	
	/** The party supports none of the offered transport methods. */
	unsupported_transports;
}
