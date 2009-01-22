package xmpp;


/**
	<a href="http://xmpp.org/extensions/xep-0071.html">XEP 0071 - XHTML-IM</a>
*/
class XHTML {
	
	public static var XMLNS = "http://jabber.org/protocol/xhtml-im";
	
	public var body : Xml;
	
	
	public function new( ?body : Xml ) {
		this.body = body;
	}
	
	
	public function toXml() : Xml {
		if( body == null ) return null;
		var x = Xml.createElement( "html" );
		x.set( "xmlns", XMLNS );
		x.addChild( body );
		return x;
	}
	
	
	#if JABBER_DEBUG public inline function toString() : String { return toXml().toString(); } #end

	
	/**
		Get the html body from a message packet.
	*/
	public static function fromMessage( m : xmpp.Message ) : Xml {
		for( p in m.properties ) {
			if( p.nodeName == "html" && p.get( "xmlns" ) == "http://jabber.org/protocol/xhtml-im" ) {
				var b = p.elements().next();
				if( b != null && b.nodeName == "body" && b.get( "xmlns" ) == "http://www.w3.org/1999/xhtml" ) {
					return b;
				}
			}
		}
		return null;
	}	
	
}
