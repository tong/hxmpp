package xmpp;


class Compression {
	
	public static var XMLNS = xmpp.NS.PROTOCOL+'/compress';
	
	/**
	*/
	public static function createPacket( methods : Array<String> ) : Xml {
		var x = Xml.createElement( "compress" );
		x.set( "xmlns", XMLNS );
		for( m in methods ) x.addChild( util.XmlUtil.createElement( "method", m ) );
		return x;
	}
	
	/**
	*/
	public static function parseMethods( x : Xml ) : Array<String> {
		var a = new Array<String>();
		for( e in x.elementsNamed( "method" ) ) a.push( e.firstChild().nodeValue );
		return a;
	}
	
}
