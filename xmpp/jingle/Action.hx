package xmpp.jingle;

/**
	Actions related to management of the overall Jingle session.
*/
enum Action {
	
	/** Accept a content-add or content-modify action received from another party. */
	content_accept;
	
	/**
		Add one or more new content types to the session.
	*/
	content_add;
	
	/**
		Change an existing content type.
	*/
	content_modify;
	
	/**
		Remove one or more content types from the session.
	*/
	content_remove;
	
	/**
		Definitively accept a session negotiation (implicitly this action also serves as a content-accept).
	*/
	session_accept;
	
	/**
		 Send session-level information / messages, such as (for Jingle audio) a ringing message.
	*/
	session_info;
	
	/**
		Request negotiation of a new Jingle session.
	*/
	session_initiate;
	
	/**
		 End an existing session.
	*/
	session_terminate;
	
	/**
		Exchange transport candidates, it is mainly used in XEP-0176 but may be used in other transport specifications.
	*/
	transport_info;
	
}
