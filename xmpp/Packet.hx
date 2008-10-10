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
	public var properties : Array<Xml>;
	//error?
	
	
	function new( ?to : String, ?from : String, ?id : String, ?lang : String ) {
		this.to = to;
		this.from = from;
		this.id = id ;
		this.lang = lang;
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
	public function toString() : String {
		return toXml().toString();
	}
	
	
	/**
		Adds the basic xmpp packet attributes to the xml.
	*/
	function addAttributes( src : Xml ) : Xml {
		if( to != null ) src.set( "to", to );
		if( from != null ) src.set( "from", from );
		if( id != null ) src.set( "id", id );
		if( lang != null ) src.set( "xml:lang", lang );
		for( p in properties ) src.addChild( p );
        return src;
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
	
	/**
		Parses/adds basic attributes to the packet.
	*/
	public static function parseAttributes( p : xmpp.Packet, src : Xml ) : xmpp.Packet {
		p.to = src.get( "to" );
		p.from = src.get( "from" );
		p.id = src.get( "id" );
		p.lang = src.get( "xml:lang" );
		return p;
	}
	
}
