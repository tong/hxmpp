package xmpp;

//TODO move to xmpp.Packet

class XMLUtil {
	
	/**
		Default XML (file) header.
	*/
	public static var HEADER = '<?xml version="1.0" encoding="UTF-8"?>';
	
	/**
	*/
	public static function createElement( n : String, d : String ) : Xml {
		var x = Xml.createElement( n );
		x.addChild( Xml.createPCData( d ) );
		return x;
	}
	
	/*
	public static function reflectAttribute<T,V>( o : T, f : String, x : Xml ) {
		Reflect.setField( o, f, x.get(f) );
	}
	*/
	
	//TODO also <?xml version="1.0"?>
	static var eheader = ~/^(\<\?xml) (.)+\?\>/; 
	//static var eheader = ~/^(\<\?xml) (version=["']1.0["']) (encoding=["']UTF-8["'])\?\>/; 
	
	/**
		Remove the XML-header.
	*/
	public static function removeXmlHeader( s : String ) : String {
		if( eheader.match( s ) )
			return s.substr( s.indexOf( "><" ) + 1, s.length );
		return s;
	}
	
}
