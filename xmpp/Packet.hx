package xmpp;


/**
	Abstract/Basic xmpp packet.
*/
class Packet {
	
	public var _type(default,null) : PacketType;
	public var to : String;
	public var from : String;
	public var id : String;	
	public var lang : String;
	public var errors : Array<Xml>;
	public var properties : Array<Xml>;
	
	
	function new( ?to : String, ?from : String, ?id : String, ?lang : String ) {
		this.to = to;
		this.from = from;
		this.id = id ;
		this.lang = lang;
		errors = new Array();
		properties = new Array();
	}

	
	/**
		Creates/Returns the xml representaion of this xmpp packet.
	*/
	public function toXml() : Xml {
		return throw "Abstract error";
	}
	
	/**
		Creates/Returns the string representaion of this xmpp packet.
	*/
	public inline function toString() : String {
		return toXml().toString();
	}
	

	/**
		Adds the basic xmpp packet attributes to the xml.
	*/
	function addAttributes( x : Xml ) : Xml {
		if( to != null ) x.set( "to", to );
		if( from != null ) x.set( "from", from );
		if( id != null ) x.set( "id", id );
		if( lang != null ) x.set( "xml:lang", lang );
		for( p in properties ) x.addChild( p );
		for( e in errors ) x.addChild( e );
        return x;
	}
	
	
	/**
		Parses xml into a xmpp.Packet object.
	*/
	public static function parse( src : Xml ) : xmpp.Packet {
		return switch( src.nodeName ) {
			case "iq" 		: cast IQ.parse( src );
			case "message"  : cast xmpp.Message.parse( src );
			case "presence" : cast Presence.parse( src );
			default : cast new PlainPacket( src );
		}
	}
	
		/* TODO
	static function parseBase( p, x : Xml ) {
		parseAttributes
		for( e in errors )
		for( p in properties ) 
	}
	*/
	/**
		Parses/adds basic attributes to the packet.
	*/
	public static function parseAttributes( p : xmpp.Packet, x : Xml ) : xmpp.Packet {
		p.to = x.get( "to" );
		p.from = x.get( "from" );
		p.id = x.get( "id" );
		p.lang = x.get( "xml:lang" );
		return p;
	}
	
}
