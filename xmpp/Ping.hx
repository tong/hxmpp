package xmpp;


/**
	<a href="http://www.xmpp.org/extensions/xep-0199.html">XEP 199 - XMPP Ping</a>
*/
class Ping {
	
	public static var XMLNS = "urn:xmpp:ping";
	
	public function new() {}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "ping" );
		x.set( "xmlns", XMLNS );
		return x;
	}
	
}
