package xmpp;

import util.XmlUtil;


/**
	IQ extension for account authenticating.
*/
class Auth {
	
	public static var XMLNS = "jabber:iq:auth";
	
	public var username : String;
	public var password : String;
	public var digest : String;
	public var resource : String;
	
	
	public function new( ?username:	String, ?password : String, ?digest : String, ?resource : String ) {
		this.username = username;
		this.password = password;
		this.digest = digest;
		this.resource = resource;
	}

	
	public function toXml() : Xml {
		var q = xmpp.IQ.createQueryXml( XMLNS );
		if( username != null ) q.addChild( XmlUtil.createElement( "username", username ) );
		if( password != null ) q.addChild( XmlUtil.createElement( "password", password ) );
		if( digest != null )   q.addChild( XmlUtil.createElement( "digest", digest ) );
		if( resource != null ) q.addChild( XmlUtil.createElement( "resource", resource ) );
		return q;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	
	public static function parse( x : Xml ) : xmpp.Auth {
		var a = new xmpp.Auth();
		xmpp.Packet.reflectPacketNodes( x, a );
		/*
		for( e in x.elements() ) {
			var v : String = null;
			try { v = e.firstChild().nodeValue; } catch( e : Dynamic ) {}
			if( v != null ) {
				switch( e.nodeName ) {
					case "username" : a.username = v;
					case "password" : a.password = v;
					case "digest"   : a.digest = v;
					case "resource" : a.resource = v;
				}
			}
		}
		*/
		return a;
	}
	
}
