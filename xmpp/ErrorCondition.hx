package xmpp;

class ErrorCondition {
	
	/**	
		The sender has sent XML that is malformed or that cannot be processed
		(e.g., an IQ stanza that includes an unrecognized value of the 'type' attribute);
		The associated error type SHOULD be "modify". 
	*/
	public static var BAD_REQUEST = "bad-request";
	
	/**	
		Access cannot be granted because an existing resource or session exists with the same name or address;
		The associated error type SHOULD be "cancel". 
	*/
	public static var CONFLICT = "conflict";
	
	/**	
		The feature requested is not implemented by the recipient or server and therefore cannot be processed;
		The associated error type SHOULD be "cancel". 
	*/
	public static var FEATURE_NOT_IMPLEMENTED = "feature-not-implemented";
	
	/**	
		The requesting entity does not possess the required permissions to perform the action;
		The associated error type SHOULD be "auth".  
	*/
	public static var FORBIDDEN = "forbidden";
	
	/**	
		The recipient or server can no longer be contacted at this address
		(the error stanza MAY contain a new address in the XML character data of the <gone/> element);
		The associated error type SHOULD be "modify".   
	*/
	public static var GONE = "gone";
	
	/**	
		The server could not process the stanza because of a misconfiguration or an otherwise-undefined internal server error;
		The associated error type SHOULD be "wait".   
	*/
	public static var INTERNAL_SERVER_ERROR = "internal-server-error";
	
	/**	
		The addressed JID or item requested cannot be found; the associated error type SHOULD be "cancel". 
	*/
	public static var ITEM_NOT_FOUND = "item-not-found";
	
	/**	
		The sending entity has provided or communicated an XMPP address (e.g., a value of the 'to' attribute)
		or aspect thereof (e.g., a resource identifier) that does not adhere to the syntax defined in Addressing Scheme (Addressing Scheme);
		The associated error type SHOULD be "modify".  
	*/
	public static var JID_MALFORMED = "jid-malformed";
	
	
	/**	
		The recipient or server understands the request but is refusing to process it because it does not meet criteria defined by the recipient or server
		(e.g., a local policy regarding acceptable words in messages);
		The associated error type SHOULD be "modify". 
	*/
	public static var NOT_ACCEPTABLE = "not-acceptable";
	
	/**	
		The recipient or server does not allow any entity to perform the action; 
		The associated error type SHOULD be "cancel". 
	*/
	public static var NOT_ALLOWED = "not-allowed";
	
	/**	
		The sender must provide proper credentials before being allowed to perform the action, or has provided improper credentials;
		The associated error type SHOULD be "auth". 
	*/
	public static var NOT_AUTHORIZED = "not-authorized";
	
	/**	
		The requesting entity is not authorized to access the requested service because payment is required;
		The associated error type SHOULD be "auth". 
	*/
	public static var PAYMENT_REQUIRED = "payment-required";
	
	/**	
		The requesting entity is not authorized to access the requested service because payment is required;
		The associated error type SHOULD be "auth". 
	*/
	public static var RECIPIENT_UNAVAILABLE = "recipient-unavailable";
	
	/**	
		The recipient or server is redirecting requests for this information to another entity,
		usually temporarily (the error stanza SHOULD contain the alternate address, which MUST be a valid JID,
		in the XML character data of the <redirect/> element);
		The associated error type SHOULD be "modify". 
	*/
	public static var REDIRECT = "redirect";
	
	/**	
		The recipient or server is redirecting requests for this information to another entity,
		usually temporarily (the error stanza SHOULD contain the alternate address, which MUST be a valid JID,
		in the XML character data of the <redirect/> element);
		The associated error type SHOULD be "modify". 
	*/
	public static var REGISTRATION_REQUIRED = "registration-required";
	
	/**	
		A remote server or service specified as part or all of the JID of the intended recipient does not exist;
		The associated error type SHOULD be "cancel". 
	*/
	public static var REMOTE_SERVER_NOT_FOUND = "remote-server-not-found";
	
	/**	
		A remote server or service specified as part or all of the JID of the intended recipient (or required to fulfill a request) could not be contacted within a reasonable amount of time;
		The associated error type SHOULD be "wait".  
	*/
	public static var REMOTE_SERVER_TIMEOUT = "remote-server-timeout";
	
	/**	
		The server or recipient lacks the system resources necessary to service the request;
		The associated error type SHOULD be "wait".  
	*/
	public static var RESOURCE_CONSTRAINT = "resource-constraint";
	
	/**	
		The server or recipient does not currently provide the requested service;
		The associated error type SHOULD be "cancel".   
	*/
	public static var SERVICE_UNAVAILABLE = "service-unavailable";
	
	/**	
		The requesting entity is not authorized to access the requested service because a subscription is required;
		The associated error type SHOULD be "auth".    
	*/
	public static var SUBSCRIPTION_REQUIRED = "subscription-required";
	
	/**	
		The error condition is not one of those defined by the other conditions in this list;
		Any error type may be associated with this condition, and it SHOULD be used only in conjunction with an application-specific condition. 
	*/
	public static var UNDEFINED_CONDITION = "undefined-condition";
	
	/**	
		The requesting entity is not authorized to access the requested service because a subscription is required;
		The associated error type SHOULD be "auth".    
	*/
	public static var UNEXPECTED_REQUEST = "unexpected-request";
	
}
