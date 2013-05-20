/*
 * Copyright (c), disktree.net
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

#if (!php&&!nodejs)
import haxe.crypto.BaseCode;
#end

#if nodejs
import js.Node;
#end

/**
	Base64 encoding/decoding utility.
*/
class Base64 {

	public static var CHARS = 'ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz0123456789+/';

	/**
	*/
	public static
	#if (nodejs||php) inline #end
	function encode( s : String ) : String {

		#if php
		return untyped __call__( "base64_encode", s );

		#elseif nodejs
		return new NodeBuffer(s).toString( NodeC.BASE64 );
		
		#else

			#if js
			if( untyped window.btoa != null )
				return untyped window.btoa( s );
			#end
			
			var suf = switch( s.length % 3 )  {
			case 2 : "=";
			case 1 : "==";
			default : "";
			};
			return BaseCode.encode( s, CHARS ) + suf;

		#end
	}

	/**
	*/
	public static
	#if (nodejs||php) inline #end
	function decode( s : String ) : String {
		
		#if php
		return untyped __call__( "base64_decode", s );

		#elseif nodejs
		return new NodeBuffer( s, NodeC.BASE64 ).toString( NodeC.ASCII );
		
		#else

			#if js
			if( untyped window.atob != null )
				untyped window.atob( s );
			#end

			while( s.charAt( s.length-1 ) == '=' )
				s = s.substr( 0, s.length-1 );
			
			return BaseCode.decode( s, CHARS );

		#end
	}

	/**
	*/
	public static
	#if (nodejs||php) inline #end
	function encodeBytes( b : Bytes ) : Bytes {

		#if php
		return untyped __call__( "base64_encode", b.getData() );
		
		#elseif nodejs
		return Bytes.ofString( new NodeBuffer( b.toString() ).toString( NodeC.BASE64 ) );

		#else
		return new BaseCode( Bytes.ofString( CHARS ) ).encodeBytes( b );
		//return fillNullbits( bc.encodeBytes( b ).toString() );
		
		#end
	}

	/**
	*/
	public static
	#if (nodejs||php) inline #end
	function decodeBytes( b : Bytes ) : Bytes {
		
		#if php
		return Bytes.ofData( untyped __call__( "base64_decode", b.getData() ) );
		
		#elseif nodejs
		return Bytes.ofString( new NodeBuffer( b.toString(), NodeC.BASE64 ).toString( NodeC.ASCII ) );
		
		#else
		return new BaseCode( Bytes.ofString( CHARS ) ).decodeBytes( b );
		
		#end
	}

	//TODO remove
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
