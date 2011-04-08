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

using xmpp.XMLUtil;

/**
	IQ extension used for inband account authentication.
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
		var x = xmpp.IQ.createQueryXml( XMLNS );
		x.addFields( this );
		/*
		if( username != null ) x.addElement( "username", username );
		if( password != null ) x.addElement( "password", password );
		if( digest != null ) x.addElement( "digest", digest );
		if( resource != null ) x.addElement( "resource", resource );
		*/
		/*
		x.addField( this, "username" );
		x.addField( this, "password" );
		x.addField( this, "digest" );
		x.addField( this, "resource" );
		*/
		//x.addFieldsAsElements( this, ["username","digest","resource","resource"] );
		/*
		if( username != null ) x.addChild( XMLUtil.createElement( "username", username ) );
		if( password != null ) x.addChild( XMLUtil.createElement( "password", password ) );
		if( digest != null )   x.addChild( XMLUtil.createElement( "digest", digest ) );
		if( resource != null ) x.addChild( XMLUtil.createElement( "resource", resource ) );
		*/
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.Auth {
		var a = new xmpp.Auth();
		//TODO  xmpp.Packet.reflectPacketNodes( x, a );
		for( e in x.elements() ) {
			var v : String = null;
			try v = e.firstChild().nodeValue catch( e : Dynamic ) {}
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
	}
	
}
