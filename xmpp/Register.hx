/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package xmpp;

/**
	XEP-0077: In-Band Registration
*/
class Register {
	
	public static var XMLNS(default,null) : String = "jabber:iq:register";
	
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
	public var form : xmpp.DataForm;
	
	public function new( ?username : String, ?password : String, ?email : String, ?name : String ) {
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
			if( form != null ) x.addChild( form.toXml() );
		}
		return x;
	}
	
	function createElement( x : Xml, id : String ) : Xml {
		if( Reflect.hasField( this, id ) ) {
			x.addChild( XMLUtil.createElement( id, Reflect.field( this, id ) ) );
			return x;
		}
		return null;
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
				case "remove" :
					p.remove = true;
					break;
				case "x" :
					if( e.get("xmlns") == xmpp.DataForm.XMLNS ) {
						p.form = xmpp.DataForm.parse( e );
					}
				}
			}
		}
		return p;
	}
	
}
