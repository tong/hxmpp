package xmpp;

/**
	<a href="http://xmpp.org/extensions/xep-0071.html">XEP 0071 - XHTML-IM</a>
*/
class XHTML {
	
	public static var XMLNS = xmpp.NS.PROTOCOL+"/xhtml-im";
	static var BODY_NS = "http://www.w3.org/1999/xhtml";
	
	public var body : String;
	
	public function new( body : String ) {
		this.body = body;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "html" );
		x.set( "xmlns", XMLNS );
		x.addChild( Xml.parse( "<body xmlns='"+BODY_NS+"'>"+body+"</body>" ) );
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}

	public static function parse( x : Xml ) : XHTML {
		for( e in x.elementsNamed( "body" ) )
			if( e.get( "xmlns" ) == BODY_NS )
				return new XHTML( parseBody( e ) );
		return null;
	}
	
	/**
		Extract the HTML body from a message packet.
	*/
	public static function fromMessage( m : xmpp.Message ) : String {
		for( p in m.properties )
			if( p.nodeName == "html" && p.get( "xmlns" ) == XMLNS )
				for( e in p.elementsNamed( "body" ) )
					return parseBody( e );
		return null;
	}	
	
	static function parseBody( x : Xml ) : String {
		var s = new StringBuf();
		for( x in x ) s.add( x.toString() );
		return s.toString();
	}
	
}
