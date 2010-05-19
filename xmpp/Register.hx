/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package xmpp;

//TODO  dataform, oob

/**
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
	public var remove : Bool;
	//public var dataform : xmpp.DataForm;
	
	public function new( ?username:	String, ?password : String, ?email : String, ?name : String ) {
		this.username = username;
		this.password = password;
		this.email = email;
		this.name = name;
		registered = remove = false;
	}

	public function toXml() : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		if( remove ) {
			x.addChild( Xml.createElement( "remove" ) );
		} else {
			createElement( x, "username" );
			createElement( x, "password" );
			createElement( x, "email" );
			createElement( x, "name" );
			createElement( x, "nick" );
			createElement( x, "first" );
			createElement( x, "last" );
			createElement( x, "address" );
			createElement( x, "city" );
			createElement( x, "state" );
			createElement( x, "zip" );
			createElement( x, "phone" );
			createElement( x, "url" );
			createElement( x, "date" );
			createElement( x, "misc" );
			createElement( x, "text" );
			createElement( x, "key" );
		}
		return x;
	}
	
	function createElement( x : Xml, id : String ) {
		return if( Reflect.hasField( this, id ) )
			x.addChild( XMLUtil.createElement( id, Reflect.field( this, id ) ) );
		else
			null;
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
				case "nick" : p.nick = v.toString();
				case "first" : p.first = v.toString();
				case "last" : p.last = v.toString();
				case "address" : p.address = v.toString();
				case "city" : p.city = v.toString();
				case "state" : p.state = v.toString();
				case "zip" : p.zip = v.toString();
				case "phone" : p.phone = v.toString();
				case "url" : p.url = v.toString();
				case "date" : p.date = v.toString();
				case "misc" : p.misc = v.toString();
				case "text" : p.text = v.toString();
				case "key" : p.key = v.toString();
				case "registered" : p.registered = true; 
				case "remove" : p.remove = true; 
			//	case "x" :
				//TODO
				//case "remove" :
				//	p.remove = true;
				//	break;
				}
			}
		}
		return p;
	}
	
}
