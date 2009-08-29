package util;

class XmlUtil {
	
	/**
		Default XML file header.
	*/
	public static var XML_HEADER = '<?xml version="1.0" encoding="UTF-8"?>';
	
	/**
		Creates a XML object from the given arguments: <name>data</name>
	*/
	public static function createElement( name : String, ?data : String ) : Xml {
		var x = Xml.createElement( name );
		if( data != null ) x.addChild( Xml.createPCData( data ) );
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
