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

class MD5Calculator {
	
	/**
	 * Parses the initial challenge and returns calculated realm and nonce
	 */
	public static function parseChallenge( challenge : String ) : { realm : String, nonce : String } {
		var c = Base64.decode( challenge );
		var s = c.split( "," );
		var elements = new Hash<String>();
		for( e in s ) {
			var s = e.split( "=" );
			elements.set( s[0], s[1] );
		}
		if( Lambda.count( elements ) == 1 && elements.exists( "rspauth" ) )
			return null;
			//return ''; // negotiation complete //TODO hmmmmmmm should be '' (??)
		return {
			realm : if( elements.exists( "realm" ) ) unquote( elements.get( "realm" ) ) else "",
			nonce : unquote( elements.get( "nonce" ) )
		};
	}
	
	/**
	 * Caluclate/Create the MD5 challenge response
	 */
	public static function run(
		host : String,
		serverType : String,
		username : String,
		realm : String,
		pass : String,
		nonce : String ) : String {
		
		var digest_uri = serverType+"/"+host;
		var cnonce = hh( Date.now().toString() );
		var a1 = h( username+":"+realm+":"+pass )+":"+nonce+":"+cnonce;
		var a2 = "AUTHENTICATE:"+digest_uri;
		
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
		//b.add( ",authzid=" );
		//b.add( quote(authzid) );
		return b.toString();
	}
	
	static inline function h( t : String)  return MD5.encode( t, true )
	static inline function hh( t : String ) : String return MD5.encode( t )
	static inline function quote( t : String ) : String return '"'+t+'"'
	static inline function unquote( t : String ) : String return t.substr( 1, t.length-2 )
	
}
