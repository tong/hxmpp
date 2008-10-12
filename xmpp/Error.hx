package xmpp;


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
		x.set( "type", Type.enumConstructor( type ) );
		if( code != -1 ) x.set( "code", Std.string( code ) );
		if( name != null ) {
			var n = Xml.createElement( name );
			n.set( "xmlns", XMLNS );
		}
		return x;
	}
	
	
	public static function parse( x : Xml ) : xmpp.Error {
		var error = new xmpp.Error();
		error.type = Type.createEnum( ErrorType, x.get( "type" ) );
		var c = x.elements().next();
//		if( c.get( "xmlns" ) != XMLNS ) throw "Invalid xmpp error";
		error.name = c.nodeName;
		try { error.text = c.firstChild().nodeValue; } catch( e : Dynamic ) {}
		return error;
	}
	
}
