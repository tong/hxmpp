/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package xmpp;

class ErrorCondition {
	
	/**	
		The sender has sent XML that is malformed or that cannot be processed
		(e.g., an IQ stanza that includes an unrecognized value of the 'type' attribute);
		The associated error type SHOULD be "modify". 
	*/
	public static inline var BAD_REQUEST = "bad-request";
	
	/**	
		Access cannot be granted because an existing resource or session exists with the same name or address;
		The associated error type SHOULD be "cancel". 
	*/
	public static inline var CONFLICT = "conflict";
	
	/**	
		The feature requested is not implemented by the recipient or server and therefore cannot be processed;
		The associated error type SHOULD be "cancel". 
	*/
	public static inline var FEATURE_NOT_IMPLEMENTED = "feature-not-implemented";
	
	/**	
		The requesting entity does not possess the required permissions to perform the action;
		The associated error type SHOULD be "auth".  
	*/
	public static inline var FORBIDDEN = "forbidden";
	
	/**	
		The recipient or server can no longer be contacted at this address
		(the error stanza MAY contain a new address in the XML character data of the <gone/> element);
		The associated error type SHOULD be "modify".   
	*/
	public static inline var GONE = "gone";
	
	/**	
		The server could not process the stanza because of a misconfiguration or an otherwise-undefined internal server error;
		The associated error type SHOULD be "wait".   
	*/
	public static inline var INTERNAL_SERVER_ERROR = "internal-server-error";
	
	/**	
		The addressed JID or item requested cannot be found; the associated error type SHOULD be "cancel". 
	*/
	public static inline var ITEM_NOT_FOUND = "item-not-found";
	
	/**	
		The sending entity has provided or communicated an XMPP address (e.g., a value of the 'to' attribute)
		or aspect thereof (e.g., a resource identifier) that does not adhere to the syntax defined in Addressing Scheme (Addressing Scheme);
		The associated error type SHOULD be "modify".  
	*/
	public static inline var JID_MALFORMED = "jid-malformed";
	
	
	/**	
		The recipient or server understands the request but is refusing to process it because it does not meet criteria defined by the recipient or server
		(e.g., a local policy regarding acceptable words in messages);
		The associated error type SHOULD be "modify". 
	*/
	public static inline var NOT_ACCEPTABLE = "not-acceptable";
	
	/**	
		The recipient or server does not allow any entity to perform the action; 
		The associated error type SHOULD be "cancel". 
	*/
	public static inline var NOT_ALLOWED = "not-allowed";
	
	/**	
		The sender must provide proper credentials before being allowed to perform the action, or has provided improper credentials;
		The associated error type SHOULD be "auth". 
	*/
	public static inline var NOT_AUTHORIZED = "not-authorized";
	
	/**	
		The requesting entity is not authorized to access the requested service because payment is required;
		The associated error type SHOULD be "auth". 
	*/
	public static inline var PAYMENT_REQUIRED = "payment-required";
	
	/**	
		The requesting entity is not authorized to access the requested service because payment is required;
		The associated error type SHOULD be "auth". 
	*/
	public static inline var RECIPIENT_UNAVAILABLE = "recipient-unavailable";
	
	/**	
		The recipient or server is redirecting requests for this information to another entity,
		usually temporarily (the error stanza SHOULD contain the alternate address, which MUST be a valid JID,
		in the XML character data of the <redirect/> element);
		The associated error type SHOULD be "modify". 
	*/
	public static inline var REDIRECT = "redirect";
	
	/**	
		The recipient or server is redirecting requests for this information to another entity,
		usually temporarily (the error stanza SHOULD contain the alternate address, which MUST be a valid JID,
		in the XML character data of the <redirect/> element);
		The associated error type SHOULD be "modify". 
	*/
	public static inline var REGISTRATION_REQUIRED = "registration-required";
	
	/**	
		A remote server or service specified as part or all of the JID of the intended recipient does not exist;
		The associated error type SHOULD be "cancel". 
	*/
	public static inline var REMOTE_SERVER_NOT_FOUND = "remote-server-not-found";
	
	/**	
		A remote server or service specified as part or all of the JID of the intended recipient (or required to fulfill a request) could not be contacted within a reasonable amount of time;
		The associated error type SHOULD be "wait".  
	*/
	public static inline var REMOTE_SERVER_TIMEOUT = "remote-server-timeout";
	
	/**	
		The server or recipient lacks the system resources necessary to service the request;
		The associated error type SHOULD be "wait".  
	*/
	public static inline var RESOURCE_CONSTRAINT = "resource-constraint";
	
	/**	
		The server or recipient does not currently provide the requested service;
		The associated error type SHOULD be "cancel".   
	*/
	public static inline var SERVICE_UNAVAILABLE = "service-unavailable";
	
	/**	
		The requesting entity is not authorized to access the requested service because a subscription is required;
		The associated error type SHOULD be "auth".    
	*/
	public static inline var SUBSCRIPTION_REQUIRED = "subscription-required";
	
	/**	
		The error condition is not one of those defined by the other conditions in this list;
		Any error type may be associated with this condition, and it SHOULD be used only in conjunction with an application-specific condition. 
	*/
	public static inline var UNDEFINED_CONDITION = "undefined-condition";
	
	/**	
		The requesting entity is not authorized to access the requested service because a subscription is required;
		The associated error type SHOULD be "auth".    
	*/
	public static inline var UNEXPECTED_REQUEST = "unexpected-request";
	
}
