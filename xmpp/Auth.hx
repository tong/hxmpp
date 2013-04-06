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

using xmpp.XMLUtil;

/**
	IQ extension used for inband account authentication.
*/
class Auth {
	
	public static var XMLNS(default,null) : String = "jabber:iq:auth";
	
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
		//if( username != null ) x.addElement( "username", username );
		//if( password != null ) x.addElement( "password", password );
		//if( digest != null ) x.addElement( "digest", digest );
		//if( resource != null ) x.addElement( "resource", resource );
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
