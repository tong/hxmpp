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
package jabber.sasl;

import jabber.util.Base64;
import jabber.util.MD5;

/**
	<a href="ftp://ietf.org//rfc/rfc2831.txt">Using Digest Authentication as a SASL Mechanism</a><br>
	<a href="http://web.archive.org/web/20050224191820/http://cataclysm.cx/wip/digest-md5-crash.html">SASL and DIGEST-MD5 for XMPP</a>
*/
class MD5Mechanism {
	
	public static var NAME = 'DIGEST-MD5';
	
	public var id(default,null) : String;
	public var serverType : String;
	
	var username : String;
	var host : String;
	var pass : String;
	var resource : String;
	
	public function new( serverType : String = "xmpp" ) {
		this.id = NAME;
		this.serverType = serverType;
	}
	
	public function createAuthenticationText( username : String, host : String, pass : String, resource : String ) : String {
		this.username = username;
		this.host = host;
		this.pass = pass;
		this.resource = resource;
		return null;
		
	}
	
	public function createChallengeResponse( challenge : String ) : String {
		
		var c = Base64.decode( challenge );
		var s = c.split( "," );
		var elements = new Hash<String>();
		for( e in s ) {
			var s = e.split( "=" );
			elements.set( s[0], s[1] );
		}
		
		if( Lambda.count( elements ) == 1 && elements.exists( "rspauth" ) ) {
			return ''; // negotiation complete
		}
	
		var realm = if( elements.exists( "realm" ) ) unquote( elements.get( "realm" ) ) else "";
		var nonce = unquote( elements.get( "nonce" ) );
		var digest_uri = serverType+"/"+host;
		//if( host != null ) digest_uri += "/"+host;
		var cnonce = hh( Date.now().toString() );
		
		// compute response
	//	var authzid = username+"@"+realm+"/"+resource;
		var a1 = h( username+":"+realm+":"+pass )+":"+nonce+":"+cnonce;
	//	a1 += ":"+authzid;
		var a2 = "AUTHENTICATE:"+digest_uri;
		
		// create response string
		var b = new StringBuf();
		b.add( "username=" );
		b.add( quote( username ) );
		b.add( ",realm=" );
		b.add( quote( realm ) );
		b.add( ",nonce=" );
		b.add( quote( nonce ) );
		b.add( ",cnonce=" );
		b.add( quote( cnonce ) );
		b.add( ",nc=00000001,qop=auth,digest-uri=" );
		b.add( quote( digest_uri ) );
		b.add( ",response=" );
		b.add( hh( hh( a1 )+":"+nonce+":00000001:"+cnonce+":"+"auth"+":"+hh( a2 ) ) );
		b.add( ",charset=utf-8" );
	//	b.add( ",authzid=" );
	//	b.add( quote(authzid) );
		return b.toString();
	}
	
	static inline function h( t : String)  {
		return MD5.encode( t, true );
	}
	
	static inline function hh( t : String ) : String {
		return MD5.encode( t );
	}
	
	static inline function quote( t : String ) : String {
		return '"'+t+'"';
	}
	
	static inline function unquote( t : String ) : String {
		return t.substr( 1, t.length-2 );
	}
	
}
