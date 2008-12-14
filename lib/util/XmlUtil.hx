package util;


class XmlUtil {
	
	/**
		Default XML file header.
	*/
	public static var XML_HEADER = '<?xml version="1.0" encoding="UTF-8"?>';
	
	/**
		Creates a xml object from the given arguments: <name>data</name>
	*/
	public static inline function createElement( name : String, ?data : String ) : Xml {
		var x = Xml.createElement( name );
		if( data != null ) x.addChild( Xml.createPCData( data ) );
		return x;
	}
	
	/**
	*/
	public static inline function createElementWithContent( name : String, ?content : String ) : Xml {
		var e = createElement( name, if( content != null ) content else "" );
		return e;
	}
	
	/**
		Removes the xml-header from the beginning of a (xml) string.
	*/
	public static inline function removeXmlHeader( s : String ) : String {
		if( s.substr( 0, 6 ) == "<?xml " ) return s.substr( s.indexOf( "><" ) + 1, s.length );
		else return s;
	}
	
}
