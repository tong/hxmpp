package xmpp;


enum ErrorType {
	
	/** Retry after providing credentials */
	auth;
	
	/** Do not retry (the error is unrecoverable)  */
	cancel;
	
	/** Proceed (the condition was only a warning)  */
	continue_;
	
	/** Retry after changing the data sent */
	modify;
	
	/** Retry after waiting (the error is temporary) */
	wait;
	
}
