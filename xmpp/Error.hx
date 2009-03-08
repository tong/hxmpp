package xmpp;


/**
	XMPP packet error extension.
*/
class Error {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-stanzas";
	
	public var type : ErrorType;
	public var code : Int;
	public var name : String; //public var conditions : Array<String>;
	public var text : String;
	
	public function new( ?type : ErrorType, ?code = -1, ?name : String, ?text : String ) {
		this.type = type;
		this.code = code;
		this.name = name;
		this.text = text;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "error" );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		if( code != -1 ) x.set( "code", Std.string( code ) );
		if( name != null ) {
			var n = Xml.createElement( name );
			n.set( "xmlns", XMLNS );
			x.addChild( n );
		}
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	
	/**
		Parses the error from a given packet.
	*/
	public static function parseFromPacket( p : xmpp.Packet ) : xmpp.Error {
		/*
		for( e in p.toXml().elements() )
			if( e.nodeName == "error" )
				return Error.parse( e );
		*/
		for( e in p.toXml().elementsNamed("error") )
			return Error.parse( e );
		return null;
	}
	
	/**
		Parses the error from given xml.
	*/
	public static function parse( x : Xml ) : xmpp.Error {
//		if( x.nodeName != "error" ) throw "This is not an error extension";
		var e = new Error( Std.parseInt( x.get( "code" ) ) );
		var et = x.get( "type" );
		if( et != null ) e.type = Type.createEnum( ErrorType, x.get( "type" ) );
		var _n = x.elements().next();
		if( _n != null ) e.name = _n.nodeName;
		return e;
	}
	
}
