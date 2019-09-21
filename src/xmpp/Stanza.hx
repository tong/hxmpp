package xmpp;

enum abstract ErrorType(String) to String {

	/** Retry after providing credentials */
	var auth;

	/** Do not retry (the error is unrecoverable)  */
	var cancel;

	/** Proceed (the condition was only a warning)  */
	var continue_ = "continue";

	/** Retry after changing the data sent */
	var modify;

	/** Retry after waiting (the error is temporary) */
	var wait;

	@:from public static function fromString( s : String ) return switch s {
		case 'auth': auth;
		case 'cancel': cancel;
		case 'continue': continue_;
		case 'modify': modify;
		case 'wait': wait;
		case _: null;
	}
}

typedef ApplicationErrorCondition = {
	var condition : String;
	var xmlns : String;
}

enum abstract ErrorCondition(String) from String to String {

	/**
		The sender has sent XML that is malformed or that cannot be processed
		(e.g., an IQ stanza that includes an unrecognized value of the 'type' attribute);
		The associated error type SHOULD be "modify".
	*/
	var bad_request = "bad-request";

	/**
		Access cannot be granted because an existing resource or session exists with the same name or address;
		The associated error type SHOULD be "cancel".
	*/
	var conflict;

	/**
		The feature requested is not implemented by the recipient or server and therefore cannot be processed;
		The associated error type SHOULD be "cancel".
	*/
	var feature_not_implemented = "feature-not-implemented";

	/**
		The requesting entity does not possess the required permissions to perform the action;
		The associated error type SHOULD be "auth".
	*/
	var forbidden;

	/**
		The recipient or server can no longer be contacted at this address
		(the error stanza MAY contain a new address in the XML character data of the <gone/> element);
		The associated error type SHOULD be "modify".
	*/
	var gone;

	/**
		The server could not process the stanza because of a misconfiguration or an otherwise-undefined internal server error;
		The associated error type SHOULD be "wait".
	*/
	var internal_server_error = "internal-server-error";

	/**
		The addressed JID or item requested cannot be found; the associated error type SHOULD be "cancel".
	*/
	var item_not_found = "item-not-found";

	/**
		The sending entity has provided or communicated an XMPP address (e.g., a value of the 'to' attribute)
		or aspect thereof (e.g., a resource identifier) that does not adhere to the syntax defined in Addressing Scheme (Addressing Scheme);
		The associated error type SHOULD be "modify".
	*/
	var jid_malformed = "jid-malformed";


	/**
		The recipient or server understands the request but is refusing to process it because it does not meet criteria defined by the recipient or server
		(e.g., a local policy regarding acceptable words in messages);
		The associated error type SHOULD be "modify".
	*/
	var not_acceptable = "not-acceptable";

	/**
		The recipient or server does not allow any entity to perform the action;
		The associated error type SHOULD be "cancel".
	*/
	var not_allowed = "not-allowed";

	/**
		The sender must provide proper credentials before being allowed to perform the action, or has provided improper credentials;
		The associated error type SHOULD be "auth".
	*/
	var not_authorized = "not-authorized";

	/**
		The requesting entity is not authorized to access the requested service because payment is required;
		The associated error type SHOULD be "auth".
	*/
	var payment_required = "payment-required";

	/**
		The requesting entity is not authorized to access the requested service because payment is required;
		The associated error type SHOULD be "auth".
	*/
	var recipient_unavailable = "recipient-unavailable";

	/**
		The recipient or server is redirecting requests for this information to another entity,
		usually temporarily (the error stanza SHOULD contain the alternate address, which MUST be a valid JID,
		in the XML character data of the <redirect/> element);
		The associated error type SHOULD be "modify".
	*/
	var redirect;

	/**
		The recipient or server is redirecting requests for this information to another entity,
		usually temporarily (the error stanza SHOULD contain the alternate address, which MUST be a valid JID,
		in the XML character data of the <redirect/> element);
		The associated error type SHOULD be "modify".
	*/
	var registration_required = "registration-required";

	/**
		A remote server or service specified as part or all of the JID of the intended recipient does not exist;
		The associated error type SHOULD be "cancel".
	*/
	var remote_server_not_found = "remote-server-not-found";

	/**
		A remote server or service specified as part or all of the JID of the intended recipient (or required to fulfill a request) could not be contacted within a reasonable amount of time;
		The associated error type SHOULD be "wait".
	*/
	var remote_server_timeout = "remote-server-timeout";

	/**
		The server or recipient lacks the system resources necessary to service the request;
		The associated error type SHOULD be "wait".
	*/
	var resource_constraint = "resource-constraint";

	/**
		The server or recipient does not currently provide the requested service;
		The associated error type SHOULD be "cancel".
	*/
	var service_unavailable = "service-unavailable";

	/**
		The requesting entity is not authorized to access the requested service because a subscription is required;
		The associated error type SHOULD be "auth".
	*/
	var subscription_required = "subscription-required";

	/**
		The error condition is not one of those defined by the other conditions in this list;
		Any error type may be associated with this condition, and it SHOULD be used only in conjunction with an application-specific condition.
	*/
	var undefined_condition = "undefined-condition";

	/**
		The requesting entity is not authorized to access the requested service because a subscription is required;
		The associated error type SHOULD be "auth".
	*/
	var unexpected_request = "unexpected-request";
}

class Error {

	public static inline var XMLNS = "urn:ietf:params:xml:ns:xmpp-stanzas";

	/** */
	public var type : ErrorType;

	/** Error generator */
	public var by : String;

	/** */
	public var condition : ErrorCondition;

	/** Describes the error in more detail */
	public var text : String;

	/** Language of the text content XML character data  */
	//public var lang : String;

	/** Application-specific error condition */
	public var app : ApplicationErrorCondition;

	public function new( type : ErrorType, condition : ErrorCondition, ?text : String, ?app : ApplicationErrorCondition ) {
		this.type = type;
		this.condition = condition;
		this.text = text;
		this.app = app;
	}

	public function toXML() : XML {
		var xml = XML.create( 'error' );
		xml.set( 'type', type );
		xml.append( XML.create( condition ).set( 'xmlns', XMLNS ) );
		if( by != null ) xml.set( 'by', by );
		if( text != null )
			xml.append( XML.create( 'text', text ).set( 'xmlns', XMLNS) );
		if( app != null && (app.condition != null && app.xmlns != null) )
			xml.append( XML.create( app.condition ).set( 'xmlns', app.xmlns ) );
		return xml;
	}

	public static function fromXML( xml : XML ) : Error {
		var condition : ErrorCondition = null;
		var text : String = null;
		var app : ApplicationErrorCondition = null;
		for( e in xml.elements ) {
			var ns = e.get( 'xmlns' );
			if( ns == XMLNS ) {
				switch e.name {
				case 'text': text = e.text;
				default: condition = e.name;
				}
			} else {
				if( ns != null )
					app = { condition: e.name, xmlns: ns };
			}
		}
		return new Error( xml.get( 'type' ), condition, text );
	}
}

class Stanza {

	/**
		JID of the intended recipient.
	*/
	public var to : String;

	/**
		JID of the sender.
	*/
	public var from : String;

	/**
		Used by the originating entity to track any response or error stanza that it might receive in relation to the generated stanza from another entity.
	*/
	public var id : String;

	/**
		Specifies the default language of any such human-readable XML character data.
	*/
	public var lang : String;

	/**
	*/
	public var error : Error;

	inline function new( ?to : String, ?from : String, ?id : String, ?lang : String ) {
        this.to = to;
        this.from = from;
        this.id = id ;
        this.lang = lang;
    }

	public function toXML() : XML
		return throw 'abstract method';

	public inline function toString() : String
		return toXML().toString();

	static function createXML( s : Stanza, name : String ) : XML {
		var x = XML.create( name );
		if( s.to != null ) x.set( 'to', s.to );
		if( s.from != null ) x.set( 'from', s.from );
		if( s.id != null ) x.set( 'id', s.id );
		if( s.lang != null ) x.set( 'xml:lang', s.lang );
		return x;
	}

	static function parseAttributes<T:Stanza>( s : T, x : XML ) : T {
        s.to = x.get( 'to' );
        s.from = x.get( 'from' );
        s.id = x.get( 'id' );
        s.lang = x.get( 'xml:lang' );
		/*
        if( xml.get( 'type' ) == 'error' ) {
            stanza.error = xmpp.Error.fromXML( xml.elements["error"][0] );
        }
		*/
        return s;
    }

}
