package xmpp;

import xml.XmlUtil;
import xmpp.Packet;


/**
	IQ extension used for client account registration/manipulation.
*/
class IQRegister {
	
	public static var XMLNS  = "jabber:iq:register";
	
	
	public var username : String;
	public var password : String;
	public var email 	: String;
	public var name	 	: String;
	
	
	public function new( ?username:	String, ?password : String, ?email : String, ?name : String ) {
		this.username = username;
		this.password = password;
		this.email = email;
		this.name = name;
	}
	
	
	public function toXml() : Xml {
		var query = xmpp.IQ.createQuery( XMLNS );
		if( username != null ) 	query.addChild( XmlUtil.createElement( "username", username ) );
		if( password != null ) 	query.addChild( XmlUtil.createElement( "password", password ) );
		if( email != null ) 	query.addChild( XmlUtil.createElement( "email", email ) );
		if( name != null ) 		query.addChild( XmlUtil.createElement( "name", name ) );
		return query;
	}
	
	
	/*
	public static function parse( src : Xml ) : Register {
		var r = new Register();
		return r;
	}
	*/
	
}
