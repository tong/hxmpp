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
package jabber.sasl;

import jabber.util.Base64;
import jabber.util.MD5;

/**
	Static methods for computing sasl-md5 credentials.
*/
class MD5Calculator {
	
	/**
	 * Parses the initial challenge and returns calculated realm and nonce
	 */
	public static function parseChallenge( challenge : String ) : { realm : String, nonce : String } {
		var c = Base64.decode( challenge );
		var s = c.split( "," );
		var elements = #if haxe3 new Map<String,String>() #else new Hash<String>() #end;
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
		var a1 = h( '$username:$realm:$pass' )+':$nonce:$cnonce';
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
		b.add( hh( hh( a1 )+':$nonce:00000001:$cnonce:auth:'+hh( a2 ) ) );
		
		b.add( ",charset=utf-8" );
		//b.add( ",authzid=" );
		//b.add( quote(authzid) );
		return b.toString();
	}
	
	static inline function h( t : String)  return MD5.encode( t, true );
	static inline function hh( t : String ) : String return MD5.encode( t );
	static inline function quote( t : String ) : String return '"$t"';
	static inline function unquote( t : String ) : String return t.substr( 1, t.length-2 );
	
}
