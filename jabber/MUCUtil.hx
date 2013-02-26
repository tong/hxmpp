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
package jabber;

/**
	Static methods for parsing of mutliuser chat addresses.
*/
class MUCUtil {
	
	/** Regular expression matching a valid MUC address */
	public static var EREG = ~/([A-Z0-9._%-]+)@([A-Z0-9.-]+)(\/([A-Z0-9._%-]+))?/i;

	/**
		Returns true if the given string is a valid muchat address.
		The 'nick' parameter indicates if a full adress (including nickname) is expected.
	*/
	public static function isValid( t : String, nick : Bool = false ) : Bool {
		if( !EREG.match( t ) )
			return false;
		return nick ? ( EREG.matched( 4 ) != null ) : true;
	}
	
	/**
		Returns the room of the muc jid.
	*/
	public static inline function getRoom( t : String ) : String {
		return JIDUtil.node( t );
	}
	
	/**
		Returns the host of the muc jid.
	*/
	public static inline function getHost( t : String ) : String {
		return getParts( t )[1];
	}
	
	/**
		Returns the occupant name of the muc jid.
	*/
	public static function getNick( t : String ) : String {
		var i = t.indexOf( "/" );
		return ( i == -1 ) ? null : t.substr( i+1 );
	}
	
	/**
		Returns array existing of roomname[0], host[1] and (optional) occupantname[2] of the given muc address.
	*/
	public static function getParts( t : String ) : Array<String> {
		var i1 = t.indexOf( "@" );
		var i2 = t.indexOf( "/" );
		return if( i2 == -1 )
			[ t.substr( 0, i1 ), t.substr( i1+1 ) ];
		else
			[ t.substr( 0, i1 ), t.substr( i1+1, i2-i1-1 ), t.substr( i2+1 ) ];
	}
		
}
