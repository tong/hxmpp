package xmpp;

/**
	Abstract base type for stanzas (<iq/>,<presence/>,<message/>)
*/
class Stanza {

	/** Intended recipient */
    public var to : String;

	/** JID of the sender */
    public var from : String;

	/** Used by the originating entity to track any response or error stanza that it might receive in relation to the generated stanza from another entity */
    public var id : String;

	/** Specifies the default language of any such human-readable XML character data. */
    public var lang : String;

    /***/
    public var error : Error;

	/** */
    public var properties : Array<XML>;

	function new( ?to : String, ?from : String, ?id : String, ?lang : String ) {
        this.to = to;
        this.from = from;
        this.id = id ;
        this.lang = lang;
		properties = [];
    }

	public function toXml() : XML
		return throw 'abstract method';

	public inline function toString() : String
		return toXml().toString();

	function addAttrs( xml : XML ) : XML {
		if( to != null ) xml.set( 'to', to );
        if( from != null ) xml.set( 'from', from );
        if( id != null ) xml.set( 'id', id );
        if( lang != null ) xml.set( 'xml:lang', lang );
		return xml;
	}

	public static function parseAttrs<T:Stanza>( stanza : T, xml : XML ) : T {
        stanza.to = xml.get( 'to' );
        stanza.from = xml.get( 'from' );
        stanza.id = xml.get( 'id' );
        stanza.lang = xml.get( 'xml:lang' );
        //TODO parse error if type=error
        if( xml.get( 'type' ) == 'error' ) {
            trace(xml);
            //error = xmpp.Error.parse( xml.element["item"]);
        }
        return stanza;
    }

}
