package xmpp;

class XMLUtil {
	
	/**
		Default XML file header.
	*/
	public static var XML_HEADER = '<?xml version="1.0" encoding="UTF-8"?>';
	
	/**
		Creates a XML object from the given arguments.
	*/
	//public static function createXmlElement( n : String, ?d : String ) : Xml {
	public static function createElement( n : String, ?d : String ) : Xml {
		var x = Xml.createElement( n );
		if( d != null ) x.addChild( Xml.createPCData( d ) );
		return x;
	}
	
	/* TODO use this, since its the same than Xml.createElement() .. inlined;
	public static function createElement( name : String, data : String ) : Xml {
		var x = Xml.createElement( name );
		x.addChild( Xml.createPCData( data ) );
		return x;
	}
	*/
	
	/**
	public static function createElementWithContent( name : String, ?content : String ) : Xml {
		return createElement( name, if( content != null ) content else "" );
	}
	*/
	
	/**
		Remove the XML-header.
	*/
	public static function removeXmlHeader( s : String ) : String {
		return if( s.substr( 0, 6 ) == "<?xml " )
			s.substr( s.indexOf( "><" ) + 1, s.length );
		else s;
	}
	
}