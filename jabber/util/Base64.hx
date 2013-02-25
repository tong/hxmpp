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
package jabber.util;

import haxe.io.Bytes;
#if nodejs
import js.Node;
#end

/**
	Base64 encoding/decoding utility.
*/
class Base64 {
	
	public static var CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';
	
	#if (cpp||flash||js||neko||java||cs)

	static var bc = new haxe.crypto.BaseCode( Bytes.ofString( CHARS ) );
	
	public static function getNullbits( s : String ) : String {
	 	return switch( s.length % 3 )  {
			case 2 : "=";
			case 1 : "==";
			default : "";
		}
	}
	
	public static inline function fillNullbits( s : String ) : String {
		return s + getNullbits(s);
	}
	
	public static function removeNullbits( s : String ) : String {
		var p = s.length-1;
		while( s.charAt( p ) == "=" ) {
			p--;
		}
		return s.substr( 0, p+1 );
	}
	
	#end
	
	public static
	//#if (nodejs||php) #end
	function encode( s : String ) : String {
		
		//#if neko
		//return sys.Base64.encode(s);
		//#end
		
		#if nodejs
		return new NodeBuffer(s).toString( NodeC.BASE64 );
		//return new Buffer( s, Node.BASE64 ).toString( Node.UTF8 );
		
		#elseif php
		return untyped __call__( "base64_encode", s );
		
		#else
			#if js
			if(  untyped window.btoa != null ) {
				return untyped window.btoa( s );
			}
	        #end
	        //TODO wtf
	      	s = removeNullbits( s );
	        var p = getNullbits(s);
	        var r = bc.encodeString( s );
	        return r+p;
	       // var r = bc.encodeString( s );
	       // return fillNullbits(r);
		#end
	}
	
	public static inline function decode( s : String ) : String {
		#if nodejs
		return new NodeBuffer( s, NodeC.BASE64 ).toString( NodeC.ASCII );
		#elseif php
		return untyped __call__( "base64_decode", s );
		#else
			#if js
			return if( untyped window.atob != null ) {
				untyped window.atob( s );
			} else {
				bc.decodeString( removeNullbits(s) );
			}
			#else
			return bc.decodeString( removeNullbits(s) );
			#end
		#end
	}
	
	public static inline function encodeBytes( b : Bytes ) : String {
		#if php
		return untyped __call__( "base64_encode", b.getData() );
		#elseif nodejs
		return  b.getData().toString( NodeC.BASE64 );
		//return new NodeBuffer( b.getData().toString( NodeC.ASCII ) );
		//return new NodeBuffer( b.getData().toString(), NodeC.BASE64 ).toString( NodeC.ASCII );
		//return b.getData().toString( NodeC.BASE64 );
		#else
		return fillNullbits( bc.encodeBytes( b ).toString() );
		#end
	}
	
	public static inline function decodeBytes( s : String ) : Bytes {
		#if php
		return Bytes.ofString( untyped __call__( "base64_decode", s ) );
		#elseif nodejs
		return Bytes.ofString( new NodeBuffer( s ).toString( NodeC.BASE64 ) );
		#else
		return bc.decodeBytes( Bytes.ofString( removeNullbits( s ) ) );
		#end
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
