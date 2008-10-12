package xmpp;


class IQ extends xmpp.Packet {
	
	public var type : IQType;
	public var ext : PacketElement;
	
	
	public function new( ?type : IQType, ?id : String, ?to : String, ?from ) {
		super( to, from, id );
		_type = xmpp.PacketType.iq;
		this.type = if( type != null ) type else xmpp.IQType.get;
	}

	
	public override function toXml(): Xml {
//		if( id == null ) throw "Invalid IQ packet, no id";
		if( type == null ) type = xmpp.IQType.get;
		var xml = super.addAttributes( Xml.createElement( "iq" ) );
		xml.set( "type", Type.enumConstructor( type ) );
		xml.set( "id", id );
		if( ext != null ) xml.addChild( ext.toXml() );
		return xml;
	}
	
	
	public static function parse( x : Xml ) : xmpp.IQ {
		var iq = new IQ();
		xmpp.Packet.parseAttributes( iq, x );
		iq.type = Type.createEnum( IQType, x.get( "type" ) );
		var ext = x.elements().next();
		if( ext != null ) iq.ext = new PlainPacket( ext );
		//TODO parse other properties (any) ..errors
		return iq;
	}
	
	/**
		Creates '<query xmlns="namspace"/>' Xml object.
	*/
    public static inline function createQuery( ns : String ) : Xml {
		var query = Xml.createElement( "query" );
		query.set( "xmlns", ns );
		return query;
	}
	
}



/**
enum IQErrorType {
	auth;
	cancel;
	continue_;
	modify;
	wait;
}
*/


/**
	IQ error packet extension.
class IQError {

    public static inline var ERROR_AUTH 	= "auth";
	public static inline var ERROR_CANCEL 	= "cancel";
	public static inline var ERROR_CONTINUE = "continue";
	public static inline var ERROR_MODIFY 	= "modify";
	public static inline var ERROR_WAIT 	= "wait";
	
	
	public var type : IQErrorType;
	public var name : String;
	public var xmlns : String;
	public var code : Int;

	
	public function new() {
		code = -1;
	}
	
	
	public function toXml() : Xml {
		//TODO
		var xml = Xml.createElement( "error" );
		xml.set( "type", switch( type ) {
			case auth : ERROR_AUTH;
			case cancel : ERROR_CANCEL;
			case continue_ : ERROR_CONTINUE;
			case modify : ERROR_MODIFY;
			case wait : ERROR_WAIT;
		} );
		xml.set( "xmlns", xmlns );
		if( code != -1 ) xml.set( "code", Std.string( code ) );
		return xml;
	}
	
	
	public static function parse( child : Xml ) : IQError {
		var error = new IQError();
		///TODO
		return error;
		
		  <error code='405' type='cancel'>
    <not-allowed xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
  </error>
  
	}
	
}

*/