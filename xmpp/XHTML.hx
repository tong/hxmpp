package xmpp;


/**
	<a href="http://xmpp.org/extensions/xep-0071.html">XEP 0071 - XHTML-IM</a>
*/
class XHTML {
	
	public static var XMLNS = "http://jabber.org/protocol/xhtml-im";
	
	public var body : Xml;
	
	public function new() {}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "html" );
		x.set( "xmlns", XMLNS );
		x.addChild( body );
		return x;
	}
	
	#if JABBER_DEBUG public inline function toString() : String { return toXml().toString(); } #end
	
	/*
	public static function parse( p : Xml ) : XHTML {
	}
	*/
	
	/**
		Extracts the html tag from a message packet.
	*/
	public static function fromMessage( m : xmpp.Message ) : XHTML {
		var xhtml = new XHTML();
		for( p in m.properties ) {
			if( p.nodeName == "html" && p.get( "xmlns" ) == "http://jabber.org/protocol/xhtml-im" ) {
				var b = p.elements().next();
				if( b != null ) {
					if( b.nodeName == "body" && b.get( "xmlns" ) == "http://www.w3.org/1999/xhtml" ) {
						xhtml.body = b;
					}
				} else {
					xhtml = null;
				}
			}
		}
		return xhtml;
	}	
	
}
