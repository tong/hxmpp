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
package jabber.util;

import haxe.io.Bytes;
#if nodejs
import js.Node;
#end

/**
	Base64 encoding/decoding utility.
*/
class Base64 {
	
	public static
	#if neko inline #end
	var CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
	
	#if neko
	static var base_encode = neko.Lib.load("std","base_encode",2);
	static var base_decode = neko.Lib.load("std","base_decode",2);
	static var BASE = Bytes.ofString( CHARS );
	#end
	
	public static
	#if (neko||nodejs||php) inline #end
	//function encode( s : String, ?base : String ) : String {
	function encode( s : String ) : String {
	
		#if neko
		//var _base = ( base != null ) ? Bytes.ofString( base ) : BASE;
        return neko.NativeString.toString(
        	base_encode( neko.NativeString.ofString( s ),
        	BASE.getData()
        ) ) + getNullbits( s );
		
		#elseif nodejs
		return new js.Buffer( s ).toString( Node.BASE64 );
		
		#elseif php
		return untyped __call__( "base64_encode", s );

        #else
        	#if js
        	if( untyped window != null && untyped window.btoa != null )
        		return untyped window.btoa( s );
        	#end
        	//var _base = ( base != null ) ? base : CHARS;
			var r = ""; 
			var p = ""; 
			var p = getNullbits( s );
			var c = 0;
			while( c < s.length ) { // increment over the length of the string, three characters at a time
	//			if( c > 0 && (c / 3 * 4) % 76 == 0 ) r += "\r\n"; // add newlines after every 76 output characters, according to the MIME specs
				var i = (s.charCodeAt(c) << 16) + ( s.charCodeAt(c+1) << 8) + s.charCodeAt(c+2); // these three 8-bit (ASCII) characters become one 24-bit number
				var n = [(i >>> 18) & 63, (i >>> 12) & 63, (i >>> 6) & 63, i & 63]; // this 24-bit number gets separated into four 6-bit numbers
				r += CHARS.charAt( n[0]) + CHARS.charAt(n[1]) + CHARS.charAt(n[2]) + CHARS.charAt(n[3] ); // those four 6-bit numbers are used as indices into the base64 character list
				c += 3;
			}
			return r.substr( 0, r.length-p.length ) + p; // add the actual padding string, after removing the zero pad
		#end
	}
	
	public static
	#if (neko||nodejs||php) inline #end
	function decode( s : String ) : String {
	
		#if neko
		return neko.NativeString.toString( base_decode( neko.NativeString.ofString( removeNullbits( s ) ), BASE.getData() ) );
		
		#elseif nodejs
		return new Buffer( s, Node.BASE64 ).toString( Node.ASCII );
		
		#elseif php
		return untyped __call__( "base64_decode", s );
		
		#else
			#if js // use native encoding if available
	        if( untyped window != null && untyped window.atob != null )
	        	return untyped window.atob( s );
	        #end
	        
			s = new EReg( '[^'+CHARS+'=]', 'g' ).replace( s, "" );
			var p = ( s.charAt(s.length - 1 ) == '=' ? 
	                ( s.charAt(s.length - 2 ) == '=' ? "AA" : "A" ) : "" );
	        var r = "";
	        s = s.substr( 0, s.length - p.length ) + p;
			var c = 0;
			while( c < s.length ) {
				var n = ( CHARS.indexOf( s.charAt(c) ) << 18 ) +
						( CHARS.indexOf( s.charAt(c+1) ) << 12 ) +
						( CHARS.indexOf( s.charAt(c+2) ) << 6 ) +
						( CHARS.indexOf( s.charAt(c+3) ) );
				r += String.fromCharCode( (n >> 16) & 0xFF ) +
					 String.fromCharCode( (n >> 8) & 0xFF ) +
					 String.fromCharCode( n & 0xFF );
				c += 4;
	        }
	        return r.substr( 0, r.length - p.length );
        
		#end
	}
	
	public static inline function encodeBytes( b : Bytes ) : String {
		#if nodejs
		return b.getData().toString( Node.BASE64 );
		#elseif php
		return untyped __call__( "base64_encode", b.getData() );
		#else
		return encode( b.toString() );
		#end
	}
	
	public static inline function decodeBytes( s : String ) : Bytes {
		#if nodejs
		return Bytes.ofData( new Buffer( s, Node.BASE64 ) );
		#elseif php
		return Bytes.ofString( untyped __call__( "base64_decode", s ) );
		#else
		return Bytes.ofString( removeNullbits( decode( s ) ) );
//		return bc.decodeBytes( Bytes.ofString( removeNullbits( t ) ) );
		#end
	}
	
	public static function getNullbits( t : String ) : String {
		var r = "";
		var c = t.length % 3;
		if( c > 0 )
			for( i in c...3 ) r += '=';
		return r;
	}
	
	public static inline function fillNullbits( t : String ) : String
		return t + getNullbits(t)
	
	public static function removeNullbits( s : String ) : String {
		//var r = ~/([a-z-A-Z0-9\+\/]+)(=+)*$/;
		//if( r.match(s) ) s = r.matched(1);
		while( s.charAt( s.length-1 ) == "=" )
			s = s.substr( 0, s.length-1 );
		return s;
	}
	
	/**
		Create a random (base64 compatible) string of given length.
	*/
	public static function random( len : Int = 1, ?chars : String ) : String {
		var n : Null<Int> = null;
		if( chars == null ) {
			chars = CHARS;
			n = CHARS.length-2;
		} else
			n = chars.length;
		var s = "";
		for( i in 0...len )
			s += chars.charAt( Std.random( n ) );
		return s;
	}
	
}
