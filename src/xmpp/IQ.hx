package xmpp;

import xmpp.Packet;


enum IQType {
	get;
	set;
	result;
	error;
}


class IQ extends Packet {
	
	public static inline var GET 	= "get";
	public static inline var SET	= "set";
    public static inline var RESULT = "result";
    public static inline var ERROR  = "error";
    
	
	public var type  : IQType;
	public var extension : PacketExtension;
//	public var child(getChild,setChild) : Xml;
	public var error : IQError;
	
	var _extension : PacketExtension;
	var _child : Xml;
	
	
	public function new( ?type : IQType, ?id : String, ?to : String, ?from ) {
		super( to, from, id );
		_type = PacketType.iq;
		this.type = if( type != null ) type else IQType.get;
	}
	
	
	public function setExtensionXml( data : Xml ) {
		extension = new PacketCustomExtension( data );
	}
	
	/*
	function getChild() : Xml {
		if( extension != null ) return extension.toXml();
		return _child;
	}
	
	function setChild( c : Xml ) : Xml {
		_child = c;
		return c;
	}
	
	function setPacketExtension( e : PacketExtension ) : PacketExtension {
		_extension = e;
		_child = e.toXml();
		return e;
	}
	*/
	
	override public function toXml(): Xml {
		if( id == null || type == null ) return null;
		var xml = super.addAttributes( Xml.createElement( "iq" ) );
		xml.set( "type", switch( type ) {
			case get 	: GET;
			case set 	: SET;
			case result : RESULT;
			case error 	: ERROR;
		} );
		xml.set( "id", id );
		if( extension != null ) xml.addChild( extension.toXml() );
	//	else if( child != null ) xml.addChild( child );
		if( error != null ) xml.addChild( error.toXml() );
		return xml;
	}
	
	
	/**
		Parses iq-xml into xmpp.IQ object.
	*/
	public static function parse( src : Xml ) : IQ {
		
		var iq = new IQ();
		Packet.parseAttributes( iq, src );
		
		var iq_type = src.get( "type" );
		iq.type = switch( iq_type ) {
			case IQ.GET 	: IQType.get;
			case IQ.SET		: IQType.set;
			case IQ.RESULT 	: IQType.result;
			case IQ.ERROR 	: IQType.error;
		}
		
		//iq.child = src.elements().next();
		var ext = src.elements().next();
		if( ext != null ) iq.extension = new PacketCustomExtension( ext );
		
		return iq;
	}
	
	
	public static function getIQType( s : String ) : IQType {
		return switch( s ) {
			case GET 	: IQType.get;
			case SET 	: IQType.set;
			case RESULT : IQType.result;
			case ERROR 	: IQType.error;
		};
	}
	
	
	/**
		Creates '<query xmlns="namspace"/>'
	*/
    public static function createQuery( namespace : String ) : Xml {
		var query = Xml.createElement( "query" );
		query.set( "xmlns", namespace );
		return query;
	}
}




enum IQErrorType {
	auth;
	cancel;
	continue_;
	modify;
	wait;
}


/**
	IQ error packet extension.
*/
class IQError {

    static inline var ERROR_AUTH 	= "auth";
	static inline var ERROR_CANCEL 	= "cancel";
	static inline var ERROR_CONTINUE= "continue";
	static inline var ERROR_MODIFY 	= "modify";
	static inline var ERROR_WAIT 	= "wait";
	
	
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
	
	/*
	public static function parse( child : Xml ) : IQError {
		var error = new IQError();
		///TODO
		return error;
		  <error code='405' type='cancel'>
    <not-allowed xmlns='urn:ietf:params:xml:ns:xmpp-stanzas'/>
  </error>
	}
	*/
}
