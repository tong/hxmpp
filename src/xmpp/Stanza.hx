package xmpp;

class Stanza {

    public var to : String;
    public var from : String;
    public var id : String;
    public var lang : String;
    public var properties : Array<Xml>;

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

	function addStanzaAttrs( xml : XML ) : XML {
		if( to != null ) xml.set( "to", to );
        if( from != null ) xml.set( "from", from );
        if( id != null ) xml.set( "id", id );
        if( lang != null ) xml.set( "xml:lang", lang );
		return xml;
	}

	public static function parseAttrs<T:Stanza>( stanza : T, xml : XML ) : T {
        stanza.to = xml.get( "to" );
        stanza.from = xml.get( "from" );
        stanza.id = xml.get( "id" );
        stanza.lang = xml.get( "xml:lang" );
        //TODO parse error if type=error
        return stanza;
    }

}
