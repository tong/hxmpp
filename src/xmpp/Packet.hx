package xmpp;

//import packet.Ty

/**
	Abstract/Basic XMPP packet.
*/
class Packet {
	
	public var _type(default,null) : PacketType;
	
	public var to   		: String;
	public var from 		: String;
	public var id 			: String;	
	public var lang 		: String;
	public var properties 	: Array<Xml>;
	
	
	function new( ?to : String, ?from : String, ?id : String, ?lang : String ) {
		this.to = to;
		this.from = from;
		this.id = id ;
		this.lang = lang;
		properties = new Array();
	}
	
	
	/**
		Creates the xml representaion of this packet.
	*/
	public function toXml() : Xml {
		return throw "Error, cannot create xml from abstract xmpp packet";
	}
	
	/**
		Creates the xml representaion of this packet as string.
	*/
	public function toString() : String {
		return toXml().toString();
	}
	
	
	/**
		Adds basic xmpp packet attributes to xml.
	*/
	function addAttributes( src : Xml ) : Xml {
		if( to != null ) 	src.set( "to", to );
		if( from != null ) 	src.set( "from", from );
		if( id != null ) 	src.set( "id", id );
		if( lang != null ) 	src.set( "xml:lang", lang );
		for( p in properties ) src.addChild( p );
        return src;
	}
	
	
	/**
		Parses xml into a xmpp.Packet object.
	*/
	public static function parse( src : Xml ) : Packet {
		var p : Packet;
		switch( src.nodeName ) {
			case "iq" 		: p = IQ.parse( src );
			case "message" 	: p = Message.parse( src );
			case "presence" : p = Presence.parse( src );
			default 		: p = new PlainPacket( src );
		}
		return p;
	}
	
	
	/**
		Adds basic attributes to every packet.
	*/
	public static function parseAttributes( p : Packet, src : Xml ) : Packet {
		p.to = src.get( "to" );
		p.from = src.get( "from" );
		p.id = src.get( "id" );
		p.lang = src.get( "xml:lang" );
		return p;
	}
	
	
	/**
		Returns the according xmpp.PacketType from given string.
	*/
	public static function getPacketType( name : String ) : PacketType {
		return switch( name ) {
			case "iq" 		: PacketType.iq;
			case "message" 	: PacketType.message;
			case "presence" : PacketType.presence;
			default 		: PacketType.custom;
		}
	}
	
	/**
		Creates a xml object: <name>data</name>
	*/
	public static function createXmlElement( name : String, data : String ) : Xml {
		var x = Xml.createElement( name );
		x.addChild( Xml.createPCData( data ) );
		return x;
	}
	
	/*
	//TODO
	public static function isValid( src : Xml ) : Bool {
		return true;
	}
	*/
}
