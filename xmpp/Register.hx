package xmpp;

import util.XmlUtil;


/**
*/
class Register {
	
	public static var XMLNS = "jabber:iq:register";
	
	public var username : String;
	public var password : String;
	public var email : String;
	public var name	: String;
	
	
	public function new( ?username:	String, ?password : String, ?email : String, ?name : String ) {
		this.username = username;
		this.password = password;
		this.email = email;
		this.name = name;
	}
	
	
	public function toXml() : Xml {
		var q = xmpp.IQ.createQuery( XMLNS );
		if( username != null ) q.addChild( XmlUtil.createXmlElement( "username", username ) );
		if( password != null ) q.addChild( XmlUtil.createXmlElement( "password", password ) );
		if( email != null ) q.addChild( XmlUtil.createXmlElement( "email", email ) );
		if( name != null ) q.addChild( XmlUtil.createXmlElement( "name", name ) );
		return q;
	}
	
}
