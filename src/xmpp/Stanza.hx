package xmpp;

enum abstract ErrorType(String) from String to String {
	/** Retry after providing credentials. **/
	var auth;

	/** Do not retry (the error is unrecoverable). **/
	var cancel;

	/** Proceed (the condition was only a warning). **/
	var continue_ = "continue";

	/** Retry after changing the data sent. **/
	var modify;

	/** Retry after waiting (the error is temporary). **/
	var wait;
}

/**
	Application-specific stanza error information.
**/
typedef ApplicationErrorCondition = {
	var condition:String;
	var xmlns:String;
	var ?properties:Array<XML>;

	/** The received application error element (with attributes), set when parsed **/
	var ?element:XML;
}

enum abstract ErrorCondition(String) from String to String {
	/**
		The sender has sent XML that is malformed or that cannot be processed (e.g., an IQ stanza that includes an unrecognized value of the `type` attribute); The associated error type SHOULD be `modify`.
	**/
	var bad_request = "bad-request";

	/**
		Access cannot be granted because an existing resource or session exists with the same name or address; The associated error type SHOULD be `cancel`.
	**/
	var conflict;

	/**
		The feature requested is not implemented by the recipient or server and therefore cannot be processed; The associated error type SHOULD be `cancel`.
	**/
	var feature_not_implemented = "feature-not-implemented";

	/**
		The requesting entity does not possess the required permissions to perform the action; The associated error type SHOULD be `auth`.
	**/
	var forbidden;

	/**
		The recipient or server can no longer be contacted at this address, typically on a permanent basis (as opposed to the `<redirect/>` error condition, which is used for temporary addressing failures); the associated error type SHOULD be `cancel` and the error stanza SHOULD include a new address (if available) as the XML character data of the `<gone/>` element.
	**/
	var gone;

	/**
		The server has experienced a misconfiguration or other internal error that prevents it from processing the stanza; the associated error type SHOULD be `cancel`.
	**/
	var internal_server_error = "internal-server-error";

	/**
		The addressed JID or item requested cannot be found; the associated error type SHOULD be `cancel`.
	**/
	var item_not_found = "item-not-found";

	/**
		The sending entity has provided or communicated an XMPP address (e.g., a value of the 'to' attribute) or aspect thereof (e.g., a resource identifier) that does not adhere to the syntax defined in Addressing Scheme (Addressing Scheme); The associated error type SHOULD be `modify`.
	**/
	var jid_malformed = "jid-malformed";

	/**
		The recipient or server understands the request but is refusing to process it because it does not meet criteria defined by the recipient or server (e.g., a local policy regarding acceptable words in messages); The associated error type SHOULD be `modify`.
	**/
	var not_acceptable = "not-acceptable";

	/**
		The recipient or server does not allow any entity to perform the action; The associated error type SHOULD be `cancel`.
	**/
	var not_allowed = "not-allowed";

	/**
		The sender must provide proper credentials before being allowed to perform the action, or has provided improper credentials; The associated error type SHOULD be `auth`.
	**/
	var not_authorized = "not-authorized";

	/**
		The requesting entity is not authorized to access the requested service because payment is required; The associated error type SHOULD be `auth`.

		Defined in RFC 3920 only, not used by RFC 6120.
	**/
	var payment_required = "payment-required";

	/**
		The entity has violated some local service policy (e.g., a message contains words that are prohibited by the service) and the server MAY choose to specify the policy in the `<text/>` element or in an application-specific condition element; The associated error type SHOULD be `modify` or `wait` depending on the policy being violated.
	**/
	var policy_violation = "policy-violation";

	/**
		The intended recipient is temporarily unavailable, undergoing maintenance, etc.; The associated error type SHOULD be `wait`.
	**/
	var recipient_unavailable = "recipient-unavailable";

	/**
		The recipient or server is redirecting requests for this information to another entity, usually temporarily (the error stanza SHOULD contain the alternate address, which MUST be a valid JID, in the XML character data of the `<redirect/>` element) The associated error type SHOULD be `modify`.
	**/
	var redirect;

	/**
		The requesting entity is not authorized to access the requested service because prior registration is necessary (examples of prior registration include members-only rooms in XMPP multi-user chat and gateways to non-XMPP instant messaging services); The associated error type SHOULD be `auth`.
	**/
	var registration_required = "registration-required";

	/**
		A remote server or service specified as part or all of the JID of the intended recipient does not exist; The associated error type SHOULD be `cancel`.
	**/
	var remote_server_not_found = "remote-server-not-found";

	/**
		A remote server or service specified as part or all of the JID of the intended recipient (or required to fulfill a request) could not be contacted within a reasonable amount of time; The associated error type SHOULD be `wait`.
	**/
	var remote_server_timeout = "remote-server-timeout";

	/**
		The server or recipient lacks the system resources necessary to service the request; The associated error type SHOULD be `wait`.
	**/
	var resource_constraint = "resource-constraint";

	/**
		The server or recipient does not currently provide the requested service; The associated error type SHOULD be `cancel`.
	**/
	var service_unavailable = "service-unavailable";

	/**
		The requesting entity is not authorized to access the requested service because a subscription is required; The associated error type SHOULD be `auth`.
	**/
	var subscription_required = "subscription-required";

	/**
		The error condition is not one of those defined by the other conditions in this list; Any error type may be associated with this condition, and it SHOULD be used only in conjunction with an application-specific condition.
	**/
	var undefined_condition = "undefined-condition";

	/**
		The recipient or server understood the request but was not expecting it at this time (e.g., the request was out of order); The associated error type SHOULD be `wait` or `modify`.
	**/
	var unexpected_request = "unexpected-request";
}

@:structInit
private class CError {
	/** How to proceed (retry, modify, ...) **/
	public var type:ErrorType;

	/** The defined error condition **/
	public var condition:ErrorCondition;

	/** Entity that generated the error **/
	public var by:String;

	/** Describes the error in more detail **/
	public var text:String;

	/** Language of `text` **/
	public var lang:String;

	/** New address of the entity for the `gone` and `redirect` conditions **/
	public var address:String;

	/** Application-specific error condition **/
	public var app:ApplicationErrorCondition;

	/** The original payload included in the error response, e.g. a data form requesting more information **/
	public var payload:XML;

	public function new(type:ErrorType, condition:ErrorCondition, ?text:String, ?app:ApplicationErrorCondition) {
		this.type = type;
		this.condition = condition;
		this.text = text;
		this.app = app;
	}
}

/**
	Stanza error ([RFC 6120 8.3](https://xmpp.org/rfcs/rfc6120.html#stanzas-error)).
**/
@:forward
abstract Error(CError) from CError {
	public static inline var XMLNS = "urn:ietf:params:xml:ns:xmpp-stanzas";

	public inline function new(type:ErrorType, condition:ErrorCondition, ?text:String, ?app:ApplicationErrorCondition)
		this = new CError(type, condition, text, app);

	@:to public inline function toBool():Bool
		return this != null;

	@:to public function toXML():XML {
		final condition = XML.create(this.condition ?? undefined_condition).set('xmlns', XMLNS);
		if (this.address != null && (this.condition == gone || this.condition == redirect))
			condition.text = this.address;
		final xml = XML.create('error').set('type', this.type ?? cancel).append(condition);
		if (this.by != null)
			xml.set('by', this.by);
		if (this.text != null)
			xml.append(XML.create('text', this.text).set('xmlns', XMLNS).set('xml:lang', this.lang));
		if (this.app != null && (this.app.condition != null && this.app.xmlns != null)) {
			var c = XML.create(this.app.condition).set('xmlns', this.app.xmlns);
			if (this.app.properties != null)
				for (e in this.app.properties)
					c.append(e);
			xml.append(c);
		}
		return xml;
	}

	/**
		Parses an `<error/>` element.

		A missing condition results in `undefined-condition`, a missing type in `cancel`.
		Of multiple `<text/>` elements the one without `xml:lang` is used (or the first).
	**/
	@:from public static function fromXML(xml:XML):Error {
		var condition:Null<ErrorCondition> = null;
		var address:Null<String> = null;
		var textElement:Null<XML> = null;
		var app:Null<ApplicationErrorCondition> = null;
		for (e in xml.elements) {
			switch e.ns {
				case Error.XMLNS:
					switch e.name {
						case 'text':
							if (textElement == null || (textElement.has('xml:lang') && !e.has('xml:lang')))
								textElement = e;
						case _:
							if (condition == null) {
								condition = e.name;
								final t:String = e.text;
								if (t != null && t.length > 0)
									address = StringTools.trim(t);
							}
					}
				case _:
					app = {
						condition: e.name,
						xmlns: e.ns,
						properties: [for (e in e.elements) e],
						element: e
					};
			}
		}
		final error = new Error(xml.get('type') ?? cancel, condition ?? undefined_condition, (textElement == null) ? null : textElement.text, app);
		error.by = xml.get('by');
		if (textElement != null)
			error.lang = textElement.get('xml:lang');
		if (condition == gone || condition == redirect)
			error.address = address;
		return error;
	}
}

abstract class Stanza {
	/**
		JID of the intended recipient.
	**/
	public var to:Null<String>;

	/**
		JID of the sender.
	**/
	public var from:Null<String>;

	/**
		Used by the originating entity to track any response or error stanza that it might receive in relation to the generated stanza from another entity.
	**/
	public var id:Null<String>;

	/**
		Specifies the default language of any such human-readable XML character data.
	**/
	public var lang:Null<String>;

	/**
		The error of a stanza of type `error`.
	**/
	public var error:Null<Error>;

	/**
		Child elements not handled by the stanza type, e.g. extension payloads.
	**/
	public var properties:Array<XML> = [];

	inline function new(?to:String, ?from:String, ?id:String, ?lang:String) {
		this.to = to;
		this.from = from;
		this.id = id;
		this.lang = lang;
	}

	public abstract function toXML():XML;

	public inline function toString():String
		return toXML().toString();

	static function createXML(s:Stanza, name:String):XML {
		final x = XML.create(name);
		if (s.to != null)
			x.set('to', s.to);
		if (s.from != null)
			x.set('from', s.from);
		if (s.id != null)
			x.set('id', s.id);
		if (s.lang != null)
			x.set('xml:lang', s.lang);
		return x;
	}

	static function parseAttributes<T:Stanza>(s:T, x:XML):T {
		s.to = x.get('to');
		s.from = x.get('from');
		s.id = x.get('id');
		s.lang = x.get('xml:lang');
		return s;
	}
}
