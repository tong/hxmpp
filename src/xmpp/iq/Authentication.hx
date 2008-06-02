package xmpp.iq;

import xmpp.Packet;


/**
	IQ extension for account authenticating.
*/
class Authentication {
	
	public static inline var XMLNS = "jabber:iq:auth";
	
	
	public var username : String;
	public var password : String;
	public var digest 	: String;
	public var resource : String;
	
	
	public function new( ?username:	String, ?password : String, ?digest : String, ?resource : String ) {
		this.username = username;
		this.password = password;
		this.digest = digest;
		this.resource = resource;
	}

	
	public function toXml() : Xml {
		var query = xmpp.IQ.createQuery( XMLNS );
		if( username != null ) 	query.addChild( Packet.createXmlElement( "username", username ) );
		if( password != null ) 	query.addChild( Packet.createXmlElement( "password", password ) );
		if( digest != null ) 	query.addChild( Packet.createXmlElement( "digest", digest ) );
		if( resource != null ) 	query.addChild( Packet.createXmlElement( "resource", resource ) );
		return query;
	}
}
