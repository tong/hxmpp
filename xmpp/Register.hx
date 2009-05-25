package xmpp;

import util.XmlUtil;


/**
	<a href="http://www.xmpp.org/extensions/xep-0077.html">XEP-0077: In-Band Registration</a>
*/
class Register {
	
	public static var XMLNS = "jabber:iq:register";
	
	public var username : String;
	public var password : String;
	public var email : String;
	public var name	: String;
	/* TODO
	public var nick : String;
	public var first : String;
	public var last	: String;
	public var address : String;
	public var city	: String;
	public var state : String;
	public var zip : String;
	public var phone : String;
	public var url : String;
	public var date	: String;
	public var misc	: String;
	public var text	: String;
	public var key	: String;
	
	public var registered : Bool;
	//public var form : xmpp.DataForm;
	*/
	
	/** */
	public var remove : Bool;
	
	
	public function new( ?username:	String, ?password : String, ?email : String, ?name : String ) {
		this.username = username;
		this.password = password;
		this.email = email;
		this.name = name;
		remove = false;
	}


	public function toXml() : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		if( remove ) {
			x.addChild( Xml.createElement( "remove" ) );
		} else {
			if( username != null ) x.addChild( XmlUtil.createElement( "username", username ) );
			if( password != null ) x.addChild( XmlUtil.createElement( "password", password ) );
			if( email != null ) x.addChild( XmlUtil.createElement( "email", email ) );
			if( name != null ) x.addChild( XmlUtil.createElement( "name", name ) );
			//...
		}
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	
	public static function parse( x : Xml ) : xmpp.Register {
		var p = new xmpp.Register();
		//xmpp.Packet.reflectPacketNodes( x, r );
		for( e in x.elements() ) {
			var v = e.firstChild();
			if( v != null ) {
				switch( e.nodeName ) {
				case "username" : p.username = v.toString();
				case "password" : p.password = v.toString();
				case "email" : p.email = v.toString();
				case "name" : p.name = v.toString();
				}
			}
		}
		return p;
	}
	
}
