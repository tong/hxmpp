package xmpp;


/**
	Xmpp packet error extension.
*/
class Error {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-stanzas";
	
	public var type : ErrorType;
	public var code : Int;
	public var name : String;
	public var text : String;
	
	
	public function new() {
		code = -1;
	}
	
	
	public function toXml() : Xml {
		var x = Xml.createElement( "error" );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		if( code != -1 ) x.set( "code", Std.string( code ) );
		if( name != null ) {
			var n = Xml.createElement( name );
			n.set( "xmlns", XMLNS );
			//..TODO
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
		for( e in p.toXml().elements() ) {
			if( e.nodeName == "error" ) return Error.parse( e );
		}
		return null;
	}
	
	/**
		Parses the error from given xml.
	*/
	public static function parse( x : Xml ) : xmpp.Error {
		if( x.nodeName != "error" ) throw "This is not an error extension";
		var e = new xmpp.Error();
		e.code = Std.parseInt( x.get( "code" ) );
		var etype = x.get( "type" );
		if( etype != null ) e.type = Type.createEnum( ErrorType, x.get( "type" ) );
		e.name = x.firstChild().toString();
		return e;
	}
	
}
