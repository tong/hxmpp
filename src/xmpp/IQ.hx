package xmpp;

@:enum abstract IQType(String) from String to String {

	/** The stanza requests information, inquires about what data is needed in order to complete further operations, */
	var get = "get";

	/** The stanza provides data that is needed for an operation to be completed, sets new values, replaces existing values, etc. */
	var set = "set";

	/** The stanza is a response to a successful get or set request. */
	var result = "result";

	/** The stanza reports an error that has occurred regarding processing or delivery of a get or set request */
	var error = "error";
}

enum IQResponse {
	result( x : XML ); //TODO
	error( e : XML ); //TODO
}

/**
	InfoQuery stanza.

	Info/Query, or IQ, is a "request-response" mechanism, similar in some ways to the Hypertext Transfer Protocol [HTTP].
	The semantics of IQ enable an entity to make a request of, and receive a response from, another entity.
	The data content of the request and response is defined by the schema or other structural definition associated with the XML namespace that qualifies the direct child element of the IQ element,
	and the interaction is tracked by the requesting entity through use of the 'id' attribute.
	Thus, IQ interactions follow a common pattern of structured data exchange such as get/result or set/result (although an error can be returned in reply to a request if appropriate).

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

*/
@:forward(
	from,to,id,lang,error,
	type,payload
)
abstract IQ(IQStanza) to Stanza {

	public inline function new( type : IQType, ?payload : XML, ?to : String, ?from : String, ?id : String )
		this = new IQStanza( type, payload, to, from, id );

	@:to public inline function toXml() : XML
		return this.toXml();

	@:to public inline function toString() : String
		return this.toString();

	//public inline function toError() : IQ
	//	return this.toString();

	@:from public static inline function fromString( str : String ) : IQ
		return fromXml( Xml.parse( str ).firstElement() );

	@:from public static function fromXml( xml : XML ) : IQ {
		var type : IQType = xml.get( 'type' );
		var iq = Stanza.parseAttrs( new IQ( type, xml.first ), xml );
		switch type {
		case error: iq.error = Error.fromXml( xml.element['error'][0] );
		default:
		}
		return iq;
	}

	public static inline function get( xmlns : String, nodeName = 'query' ) : IQ
		return new IQ( IQType.get, XML.create( nodeName ).set( 'xmlns', xmlns ) );

	public static inline function set( payload : XML ) : IQ
		return new IQ( IQType.set, payload );

	public static inline function result( iq : IQ, ?payload : XML, ?from : String ) : IQ {
		if( payload == null ) payload = iq.payload;
		return new IQ( IQType.result, payload, iq.from, from, iq.id );
	}

	public static function createErrorResponse( iq : IQ, error : Error ) : IQ {
		var r = new IQ( IQType.error, null, iq.from ); //, iq.to );
		r.id = iq.id;
		r.error = error;
		return r;
	}
}

private class IQStanza extends Stanza {

    public static inline var NAME = 'iq';

    /** Either: get/set/result/error */
	public var type : IQType;

	/** The exclusive child element (mostly: '<query xmlns="ext-namspace"/>') */
	public var payload : XML;

    public function new( ?type : IQType, ?payload : XML, ?to : String, ?from : String, ?id : String ) {
		super( to, from, id );
		this.type = type;
		this.payload = payload;
	}

    public override function toXml() : Xml {
		var xml = addAttrs( XML.create( NAME ) ).set( "type", (type != null) ? type : IQType.get );
		if( payload != null ) xml.append( payload );
		if( error != null ) xml.append( error.toXml() );
		return xml;
	}
}
