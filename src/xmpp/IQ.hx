package xmpp;

enum abstract IQType(String) to String {
	/**
		The stanza requests information, inquires about what data is needed in order to complete further operations.
	 */
	var Get = "get";

	/**
		The stanza provides data that is needed for an operation to be completed, sets new values, replaces existing values, etc.
	 */
	var Set = "set";

	/**
		The stanza is a response to a successful get or set request.
	 */
	var Result = "result";

	/**
		The stanza reports an error that has occurred regarding processing or delivery of a get or set request.
	 */
	var Error = "error";

	@:from public static function fromString(s:String)
		return switch s {
			case 'get': Get;
			case 'set': Set;
			case 'result': Result;
			case 'error': Error;
			case null, _: null;
		}
}

/**
	Info/Query, or IQ, is a "request-response" mechanism, similar in some ways to the Hypertext Transfer Protocol [HTTP].
	The semantics of IQ enable an entity to make a request of, and receive a response from, another entity.
	The data content of the request and response is defined by the schema or other structural definition associated with
	the XML namespace that qualifies the direct child element of the IQ element, and the interaction is tracked by the
	requesting entity through use of the 'id' attribute.
	Thus, IQ interactions follow a common pattern of structured data exchange such as get/result or set/result (although
	an error can be returned in reply to a request if appropriate)

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
@:forward(from, to, id, lang, error, type, payload)
@:forwardStatics(createResult)
abstract IQ(IQStanza) to Stanza {
	public static inline var NAME = 'iq';

	public inline function new(?payload:Payload, type = IQType.Get, ?id:String, ?to:String, ?from:String)
		this = new IQStanza(payload, type, id, to, from);

	@:to public inline function toXML():XML
		return this.toXML();

	@:to public inline function toString():String
		return this.toXML().toString();

	@:from public static inline function fromString(str:String):IQ
		return IQStanza.parse(XML.parse(str));

	@:from public static inline function fromXML(xml:XML):IQ
		return IQStanza.parse(xml);
}

private class IQStanza extends Stanza {

	/** Either: get/set/result/error */
	public var type:IQType;

	/** The exclusive child element (mostly: '<query xmlns="ext-namspace"/>') */
	public var payload:Payload;

	public var xmlns(get,never):String;
	inline function get_xmlns():String
		return (payload != null) ? payload.xmlns : null;

	@:allow(xmpp.IQ)
	function new(?payload:Payload, type:IQType, ?id:String, ?to:String, ?from:String) {
		super(to, from, id);
		this.type = type;
		this.payload = payload;
	}

	public function toXML():XML {
		var xml = Stanza.createXML(this, IQ.NAME);
		xml.set('type', type);
		if (payload != null)
			xml.append(payload);
		if (error != null)
			xml.append(error.toXML());
		return xml;
	}

	public static function parse(xml:XML):IQ {
		var iq = Stanza.parseAttributes(new IQ(null, xml.get('type')), xml);
		switch iq.type {
        case Error:
            iq.error = xmpp.Stanza.Error.fromXML(xml.firstElement);
        case Get, Set, Result:
            iq.payload = xml.firstElement;
		}
		return iq;
	}

    public static inline function createResult(iq:IQ, payload:Payload, ?from: String) {
        return new IQ(payload, Result, iq.id, iq.from, from);
    }
}

@:forward
@:forwardStatics
abstract Payload(XML) from XML to XML {

	public var xmlns(get,set):String;
	inline function get_xmlns():String
		return this.get('xmlns');
	inline function set_xmlns(s:String):String
		return this.set('xmlns', s);

	public var content(get,set):XML;
	inline function get_content():XML
		return this.firstElement;
	inline function set_content(x:XML):XML {
		for (e in this.elements)
			this.removeChild(e);
		return this.append(x);
	}

	inline function new(xml:XML) this = xml;

	public static function create(xmlns:String, ?elements:Iterable<XML>, name = 'query'):Payload {
		var xml = XML.create(name).set('xmlns', xmlns);
        if(elements != null) {
            //xml.elements = elements;
            for(e in elements) xml.append(e);
        }
		// if (content != null)
		// 	xml.append(content);
        // if(elements != null) {
        //     
        // }
		return new Payload(xml);
	}

	@:from public static inline function fromString(xmlns:String):Payload
		return new Payload(XML.create('query').set('xmlns', xmlns));
}
