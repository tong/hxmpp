package xmpp;

/**
	Abstract base for XMPP packets.
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
		Creates/Returns the XML representation of this XMPP packet.
	*/
	public function toXml() : Xml {
		return throw new error.AbstractError();
	}
	
	/**
		Creates/Returns the string representation of this XMPP packet.
	*/
	public inline function toString() : String {
		return toXml().toString();
	}

	/**
		Adds the basic packet attributes to the given XML.
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
		Parses given XML into a XMPP packet object.
	*/
	public static function parse( x : Xml ) : xmpp.Packet {
		return switch( x.nodeName ) {
			case "iq" 		: cast IQ.parse( x );
			case "message"  : cast xmpp.Message.parse( x );
			case "presence" : cast Presence.parse( x );
			default : cast new PlainPacket( x );
		}
	}
	
	/**
		Parses/adds basic attributes to the XMPP packet.
	*/
	static function parseAttributes( p : xmpp.Packet, x : Xml ) : xmpp.Packet {
		p.to = x.get( "to" );
		p.from = x.get( "from" );
		p.id = x.get( "id" );
		p.lang = x.get( "xml:lang" );
		return p;
	}
	
	/**
		Reflects the elements of the XML into the packet.
		TODO remove
	*/
	public static function reflectPacketNodes<T>( x : Xml, p : T ) : T {
		for( e in x.elements() ) {
			var v : String = null;
			try {
				v = e.firstChild().nodeValue;
			} catch( e : Dynamic ) {
				continue;
			};
			if( v != null )
				Reflect.setField( p, e.nodeName, v );
		}
		return p;
	}
	
	/*
	public static function createPacketElementXml<T>( o : T, name : String ) : Xml {
		trace( Reflect.field( o, name ) );
		var v = Reflect.field( o, name );
		if( v == null ) return null;
		return util.XmlUtil.createElement( name, v );
	}
*/
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
	/*
	static inline function parsePacketBase( p : xmpp.Packet, x : Xml ) {
		xmpp.Packet.parseAttributes( p, x );
		xmpp.Packet.parseChilds( p, x );
	}
	*/
}
