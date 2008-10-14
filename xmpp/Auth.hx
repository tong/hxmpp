package xmpp;

import util.XmlUtil;


/**
	IQ extension used for account authenticating.
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
		var query = xmpp.IQ.createQuery( XMLNS );
		if( username != null ) query.addChild( XmlUtil.createElement( "username", username ) );
		if( password != null ) query.addChild( XmlUtil.createElement( "password", password ) );
		if( digest != null )   query.addChild( XmlUtil.createElement( "digest", digest ) );
		if( resource != null ) query.addChild( XmlUtil.createElement( "resource", resource ) );
		return query;
	}
		
	public function toString() : String {
		return toXml().toString();
	}
	
	
	public static function parse( x : Xml ) : xmpp.Auth {
		var a = new xmpp.Auth();
		// TODO probe
		try {
			xmpp.XMPPStream.reflectPacketNodes( x, a );
		} catch( e : Dynamic ) {
			trace( "Error reflecting packet nodes "+e );
		}
		return a;
		/*
		var a = new xmpp.Auth();
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
		return a;
		*/
	}
	
	/**
		Returns true if this the given xml is a valid formed auth packet.
		
	public static function check() : Bool {
	}
	*/
	
}
