package xmpp;

import util.XmlUtil;


/**

	TODO check schema
	<a href="http://www.xmpp.org/extensions/xep-0077.html">XEP-0077: In-Band Registration</a>
*/
class Register {
	
	public static var XMLNS = "jabber:iq:register";
	
	public var username : String;
	public var password : String;
	public var email : String;
	public var name	: String;
	
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
	
	public var remove : Bool;
	
	
	public function new( ?username:	String, ?password : String, ?email : String, ?name : String ) {
		this.username = username;
		this.password = password;
		this.email = email;
		this.name = name;
	}


	public function toXml() : Xml {
		var q = xmpp.IQ.createQuery( XMLNS );
		if( remove ) {
			q.addChild( Xml.createElement( "remove" ) );
			return q;
		}
		if( username != null ) q.addChild( XmlUtil.createElement( "username", username ) );
		if( password != null ) q.addChild( XmlUtil.createElement( "password", password ) );
		if( email != null ) q.addChild( XmlUtil.createElement( "email", email ) );
		if( name != null ) q.addChild( XmlUtil.createElement( "name", name ) );
		//...
		return q;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	
	public static function parse( x : Xml ) : xmpp.Register {
		var r = new xmpp.Register();
		xmpp.Packet.reflectPacketNodes( x, r );
		/*
		for( e in x.elements() ) {
			var v : String = null;
			try { v = e.firstChild().nodeValue; } catch( e : Dynamic ) {}
			if( v != null ) {
				switch( e.nodeName ) {
					case "username" : r.username = v;
					case "password" : r.password = v;
					case "email"   : r.email = v;
					case "name" : r.name = v;
				}
			}
		}
		*/
		return r;
	}
	
}
