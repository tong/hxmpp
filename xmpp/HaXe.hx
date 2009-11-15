package xmpp;

class HaXe {

	public static inline var XMLNS = "http://haxe.org/remoting";
	
	public static function create( ?data : String ) : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		if( data != null ) x.addChild( Xml.createPCData( data ) );
		return x;
	}
	
	public static inline function getData( x : Xml ) : String {
		return x.firstChild().nodeValue;
	}
	
}
