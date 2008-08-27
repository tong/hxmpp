package jabber.roster;


enum SubscriptionMode {
	
	/** Accepts all subscription and unsubscription requests. */
	acceptAll;
	//acceptAll( subscribe : Bool );
	
	/** Rejects all subscription requests. */
	rejectAll;

	/** */
	manual;
	
}
