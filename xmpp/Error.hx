package xmpp;


/**
	Error xmpp packet extension.
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
		x.set( "type", Type.enumConstructor( type ) );
		if( code != -1 ) x.set( "code", Std.string( code ) );
		if( name != null ) {
			var n = Xml.createElement( name );
			n.set( "xmlns", XMLNS );
			//..
		}
		return x;
	}
	
	
	/**
		Parses the error from a given packet.
	*/
	public static function parsePacket( p : xmpp.Packet ) : xmpp.Error {
		for( e in p.toXml().elements() ) {
			if( e.nodeName == "error" ) return Error.parse( e );
		}
		return null;
	}
	
	/**
		Parses the error from given xml.
	*/
	public static function parse( x : Xml ) : xmpp.Error {
		var e = new xmpp.Error();
		e.code = Std.parseInt( x.get( "code" ) );
		e.type = Type.createEnum( ErrorType, x.get( "type" ) );
		for( c in x.elements() ) {
			if( c.get( "xmlns" ) != XMLNS ) throw "Invalid xmpp error";
			e.name = c.nodeName;
			break;
		}
		return e;
	}
	
}
