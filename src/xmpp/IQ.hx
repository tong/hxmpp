package xmpp;

import xmpp.Stanza;

enum abstract IQType(String) from String to String {
	/**
		The stanza requests information, inquires about what data is needed in order to complete further operations.
	**/
	var Get = "get";

	/**
		The stanza provides data that is needed for an operation to be completed, sets new values, replaces existing values, etc.
	**/
	var Set = "set";

	/**
		The stanza is a response to a successful get or set request.
	**/
	var Result = "result";

	/**
		The stanza reports an error that has occurred regarding processing or delivery of a get or set request.
	**/
	var Error = "error";
}

/**
	Info/Query *request-response* mechanism stanza.

	The semantics of IQ enable an entity to make a request of, and receive a response from, another entity.
	The data content of the request and response is defined by the schema or other structural definition associated with the XML namespace that qualifies the direct child element of the `IQ` element, and the interaction is tracked by the requesting entity through use of the `id` attribute.

	Thus, `IQ` interactions follow a common pattern of structured data exchange such as *get/result* or *set/result* (although an error can be returned in reply to a request if appropriate).

		Requesting                  Responding
		  Entity                      Entity
		----------                  ----------
			|                            |
			| <iq id='1' type='get'>     |
			|   [ ... payload ... ]      |
			| </iq>                      |
			| -------------------------> |
			|                            |
			| <iq id='1' type='result'>  |
			|   [ ... payload ... ]      |
			| </iq>                      |
			| <------------------------- |
			|                            |
			| <iq id='2' type='set'>     |
			|   [ ... payload ... ]      |
			| </iq>                      |
			| -------------------------> |
			|                            |
			| <iq id='2' type='error'>   |
			|   [ ... condition ... ]    |
			| </iq>                      |
			| <------------------------- |
			|                            |
**/
@:forward(from, to, id, lang, error, type, payload, xmlns, createResult, createError)
abstract IQ(IQStanza) to Stanza {
	public static inline var NAME = 'iq';

	public inline function new(?payload:Payload, type = IQType.Get, ?id:String, ?to:String, ?from:String)
		this = new IQStanza(payload, type, id, to, from);

	@:to public inline function toXML():XML
		return this.toXML();

	@:to public inline function toString():String
		return this.toXML().toString();

	@:from public static inline function fromString(str:String):IQ
		return IQStanza.parse(XML.fromString(str));

	@:from public static inline function fromXML(xml:XML):IQ
		return IQStanza.parse(xml);
}

private class IQStanza extends Stanza {
	/** Either: get/set/result/error **/
	public var type:IQType;

	/** The exclusive child element (mostly: `<query xmlns="extension-namespace"/>`) **/
	public var payload:Null<Payload>;

	/** Payload namespace **/
	public var xmlns(get, never):Null<String>;

	inline function get_xmlns():Null<String>
		return (payload != null) ? payload.xmlns : null;

	@:allow(xmpp.IQ)
	function new(?payload:Payload, type:IQType, ?id:String, ?to:String, ?from:String) {
		super(to, from, id);
		this.type = type;
		this.payload = payload;
	}

	public function toXML():XML {
		final xml = Stanza.createXML(this, IQ.NAME).set("type", type);
		if (payload != null)
			xml.append(payload);
		if (error != null)
			xml.append(error.toXML());
		return xml;
	}

	/**
		Parses an `<iq/>` element.

		The `type` is taken as is: it is `null` if missing and may be an invalid value (see `Stream` for the handling of invalid IQs).
	**/
	public static function parse(xml:XML):IQ {
		final iq = Stanza.parseAttributes(new IQ(), xml);
		iq.type = xml.get('type');
		switch iq.type {
			case Error:
				// The original payload may be included before the <error/> element
				for (e in xml.elements) {
					if (e.name == 'error')
						iq.error = xmpp.Stanza.Error.fromXML(e);
					else if (iq.payload == null)
						iq.payload = e;
				}
			case _:
				iq.payload = xml.firstElement;
		}
		return iq;
	}

	/**
		Creates the `result` response to this request.
	**/
	public inline function createResult(?payload:Payload):IQ
		return new IQ(payload, Result, this.id, this.from);

	/**
		Creates the `error` response to this request.
	**/
	public function createError(e:xmpp.Stanza.Error):IQ {
		final r = new IQ(null, Error, this.id, this.from);
		r.error = e;
		return r;
	}
}

/**
	The child element of an IQ, qualified by the namespace of the extension (e.g. `<query xmlns="jabber:iq:roster"/>`).

	A `String` converts implicitly to a `<query/>` element with that string as **namespace**:
	`stream.get("jabber:iq:version", handler)` sends `<query xmlns="jabber:iq:version"/>`.
	To parse XML use `XML.fromString`.
**/
@:forward
@:forwardStatics
abstract Payload(XML) from XML to XML {
	/** Namespace of the payload **/
	public var xmlns(get, set):String;

	inline function get_xmlns():String
		return this.get('xmlns');

	inline function set_xmlns(s:String):String
		return this.set('xmlns', s);

	/** First child element of the payload, or `null` **/
	public var content(get, never):XML;

	inline function get_content():XML
		return this.firstElement;

	inline function new(xml:XML)
		this = xml;

	/**
		Returns the stanza error if this is an `<error/>` element, or `null`.
	**/
	public function toError():Null<xmpp.Stanza.Error> {
		return (this.name != "error") ? null : xmpp.Stanza.Error.fromXML(this);
	}

	/**
		Creates a payload element `name` qualified by namespace `xmlns`.
	**/
	public static inline function create(xmlns:String, name = 'query'):Payload
		return new Payload(XML.create(name).set('xmlns', xmlns));

	/**
		Creates a `<query/>` element qualified by namespace `xmlns`.
	**/
	@:from public static inline function fromString(xmlns:String):Payload
		return new Payload(XML.create('query').set('xmlns', xmlns));
}
