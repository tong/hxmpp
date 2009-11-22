package xmpp;

/**
	haXe/XMPP remoting extension parsing utilities.
*/
class HXR {

	public static inline var XMLNS = "http://haxe.org/hxr";
	//public static inline var XMLNS_CALL = XMLNS+"/call";
	//public static inline var XMLNS_RESPONSE = XMLNS+"/response";
	
	public static inline function create( ?data : String ) : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		if( data != null ) x.addChild( Xml.createPCData( data ) );
		return x;
	}
	
	public static inline function getData( x : Xml ) : String {
		return x.firstChild().nodeValue;
	}
	
}
