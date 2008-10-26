package xmpp;


/**
	Error xmpp packet extension.
*/
class Error {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-stanzas";
	
	public static var BAD_REQUEST 	= "bad-request";
	public static var CONFLICT 		= "conflict";
	//..
	
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
			//..TODO
		}
		return x;
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
		if( x.nodeName != "error" ) throw "This is not an error extension";//TODO throw new jabber.error.XMPPParseError();
		var e = new xmpp.Error();
		e.code = Std.parseInt( x.get( "code" ) );
		e.type = Type.createEnum( ErrorType, x.get( "type" ) );
		var err = x.elements().next();
		if( err != null && err.get( "xmlns" ) != XMLNS ) throw new error.Exception( "Invalid xmpp error" );
		e.name = err.nodeName;
		return e;
	}
	
}
