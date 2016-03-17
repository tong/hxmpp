package xmpp;

@:enum abstract IQType(String) from String to String {
	var get = "get";
	var set = "set";
	var result = "result";
	var error = "error";
}

enum IQResponse {
	result( payload : XML );
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
private class IQStanza extends Stanza {

    public static inline var NAME = 'iq';

    /** Either: get/set/result/error */
	public var type : IQType;

	/** The exclusive query child (mostly: '<query xmlns="ext-namspace"/>') */
	public var payload : XML;

    public function new( ?type : IQType, ?payload : XML, ?to : String, ?from : String, ?id : String ) {
		super( to, from, id );
		this.type = type;
		this.payload = payload;
	}

    public override function toXml() : Xml {
		var xml = addStanzaAttrs( XML.create( NAME ) ).set( "type", (type != null) ? type : get );
		if( payload != null ) xml.append( payload );
		return xml;
	}
}

@:forward(
	from,to,id,lang,
	type,payload
)
abstract IQ(IQStanza) to Stanza {

	public inline function new( ?type : IQType, ?payload : XML, ?to : String, ?from : String, ?id : String )
		this = new IQStanza( type, payload, to, from, id );

	@:to public inline function toXml() : XML
		return this.toXml();

	@:to public inline function toString() : String
		return this.toString();

	@:from public static inline function fromString( str : String ) : IQ
		return fromXml( Xml.parse( str ).firstElement() );

	@:from public static function fromXml( xml : XML ) : IQ {
		var iq = new IQ( xml.get('type'), xml.firstElement() );
		Stanza.parseAttrs( iq, xml );
		for( e in xml.elements() ) {
			switch e.name {
			case "error" :
	            trace("TODO");
			default:
			}
		}
		return iq;
	}

	public static inline function get( xmlns : String, queryName = 'query' ) : IQ return new IQ( IQType.get, XML.create( queryName ).set('xmlns',xmlns) );
	public static inline function set( payload : XML ) : IQ return new IQ( IQType.set, payload );

}
