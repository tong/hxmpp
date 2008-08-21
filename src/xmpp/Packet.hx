package xmpp;



/**
	Abstract/Basic xmpp packet.
*/
class Packet {
	
	//public static var DEFAULT_LANGUAGE = getSysLang();
	
	
	public var _type(default,null) : PacketType;
	
	public var to   		: String;
	public var from 		: String;
	public var id 			: String;	
	public var lang 		: String;
	public var properties 	: Array<Xml>;
	//public var extension 	: Array<IPacketExtension>;
	
	
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
		Creates/Returns the xml representaion of this xmpp packet as string.
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
		Parses/adds basic attributes to the packet.
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

	
	/*
	public static function isValid( src : Xml ) : Bool {
		//TODO
		return true;
	}
	*/
	
}
