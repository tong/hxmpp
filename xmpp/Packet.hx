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
	public var errors : Array<xmpp.Error>;
	
	
	function new( ?to : String, ?from : String, ?id : String, ?lang : String ) {
		this.to = to;
		this.from = from;
		this.id = id ;
		this.lang = lang;
		errors = new Array();
		properties = new Array();
	}

	
	/**
		Creates/Returns the xml representation of this XMPP packet.
	*/
	public function toXml() : Xml {
		return throw new error.AbstractError();
	}
	
	/**
		Creates/Returns the string representaion of this xmpp packet.
	*/
	public inline function toString() : String {
		return toXml().toString();
	}
	

	/**
		Adds the basic xmpp packet attributes to the given xml.
	*/
	function addAttributes( x : Xml ) : Xml {
		if( to != null ) x.set( "to", to );
		if( from != null ) x.set( "from", from );
		if( id != null ) x.set( "id", id );
		if( lang != null ) x.set( "xml:lang", lang );
		for( p in properties ) x.addChild( p );
		for( e in errors ) x.addChild( e.toXml() );
        return x;
	}

	
	/**
		Parses xml into a xmpp.Packet object.
	*/
	public static function parse( x : Xml ) : xmpp.Packet {
		return switch( x.nodeName ) {
			case "iq" 		: cast IQ.parse( x );
			case "message"  : cast xmpp.Message.parse( x );
			case "presence" : cast Presence.parse( x );
			default : cast new PlainPacket( x );
		}
	}
	
	/*
	public static function reflectPacketAttributes<T>( x : Xml, p : T ) : T {
		for( a in x.attributes ) {
		}
	}
	public static function reflectPacketAttribute<T>( x : Xml, p : T, id : String ) : T {
		for( a in x.attributes ) {
		}
	}
	*/

	/**
		Reflects the elements of the xml into the packet.
	*/
	public static function reflectPacketNodes<T>( x : Xml, p : T ) : T {
		for( e in x.elements() ) {
			var v : String = null;
			try {
				v = e.firstChild().nodeValue;
			} catch( e : Dynamic ) {};
			if( v != null ) Reflect.setField( p, e.nodeName, v );
		}
		return p;
	}
	
	/**
		Parses/adds basic attributes to the packet.
	*/
	static inline function parseAttributes( p : xmpp.Packet, x : Xml ) : xmpp.Packet {
		p.to = x.get( "to" );
		p.from = x.get( "from" );
		p.id = x.get( "id" );
		p.lang = x.get( "xml:lang" );
		return p;
	}
	
	/**
	*/
	static inline function parseChilds( p : xmpp.Packet, x : Xml ) : xmpp.Packet {
		for( c in x.elements() ) {
			switch( c.nodeName ) {
				case "error" : p.errors.push( xmpp.Error.parse( c ) );
	//			default : p.properties.push( c );
			}
		}
		return p;
	}
	
	static inline function parsePacketBase( p : xmpp.Packet, x : Xml ) {
		xmpp.Packet.parseAttributes( p, x );
		xmpp.Packet.parseChilds( p, x );
	}
	
}
