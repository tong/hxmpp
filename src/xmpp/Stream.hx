package xmpp;



class Stream {
	
	public static inline var XMLNS_CLIENT = "jabber:client";
	public static inline var XMLNS_SERVER = "jabber:client";
	public static inline var XMLNS_COMPONENT = "jabber:component:accept";
	
	static inline var reg_stream = new EReg( "stream:stream", "" );
	static inline var reg_stream_features = new EReg( "stream:features", "" );
	static inline var reg_stream_error = new EReg( "stream:error", "" );
	//...
	
	
	/**
	*/
	public static function createOpenStream( xmlns : String, to : String,
											 ?version : String, ?lang : String, ?xmlHeader : Bool ) : String {
		
		trace("SSSSTREAMMMM");
		if( xmlHeader == null ) xmlHeader = true;
		var buf = new StringBuf();
		buf.add( '<stream:stream xmlns="' );
		buf.add( xmlns );
		buf.add( '" xmlns:stream="http://etherx.jabber.org/streams" to="' );
		buf.add( to );
		buf.add( '"' );
		if( version != null ) {
			buf.add( ' version="' );
			buf.add( version );
			buf.add( '"' );
		}
		if( lang != null ) {
			buf.add( ' xml:lang="' );
			buf.add( lang );
			buf.add( '"' );
		}
		buf.add( '>' );
		return if( xmlHeader ) '<?xml version="1.0" encoding="UTF-8"?>' + buf.toString();
		else buf.toString();
	}
	
	
	/**
	*/
	public static function isStream( src : String ) : Bool {
 		var r : EReg = ~/stream:([a-z])/;
		return r.match( src );
	}
	
	
	/**
	*/
	public static function getStreamType( s : String ) : String {
		return if( reg_stream.match( s ) ) "stream";
		  else if( reg_stream_features.match( s ) ) "features";
		  else if( reg_stream_error.match( s ) ) "error";
		//else if( new EReg( "?" ).match( src ) ) return "close";
		  else null;
	}
	
	
	/*
	//TODO
	public static function parseStreamFeatures( src : Xml ) : List<StreamFeature> {
		for( e in src.elements() ) {
			switch( e.nodeName ) {
				case "starttls" :
				case "mechanisms" :
				case "compression" :
				case "auth" :
				case "register" :
			}
		}
	}
	*/
}
