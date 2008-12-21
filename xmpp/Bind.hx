package xmpp;

import util.XmlUtil;


/**
	IQ extension used to bind a resource.
*/
class Bind {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-bind";
	
	public var resource : String;
	public var jid : String;
	
	public function new( ?resource : String, ?jid : String) {
		this.resource = resource;
		this.jid = jid;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "bind" );
		x.set( "xmlns", XMLNS );
		if( resource != null ) x.addChild( XmlUtil.createElement( "resource", resource ) );
		if( jid != null ) x.addChild( XmlUtil.createElement( "jid", jid ) );
		return x;
	}
	
	#if JABBER_DEBUG public inline function toString() : String { return toXml().toString(); } #end
	
	public static function parse( x : Xml ) : xmpp.Bind {
		var b = new Bind();
		//Packet.reflectPacketNodes( x, b );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
				case "resource" : b.resource = e.firstChild().nodeValue;
				case "jid" : b.jid = e.firstChild().nodeValue;
			}
		}
		return b;
	}
	
}
