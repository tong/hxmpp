/*
 * Copyright (c), disktree
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

#if (js&&nodejs)
import js.Node;
#end

class Base64 {

	public static inline function encode( s : String ) : String {
		
		#if php
		return untyped __call__( "base64_encode", s );
		
	//	#elseif hxssl
	//	return sys.crypto.Base64.encode(s);

		#elseif js
			#if nodejs
			return new js.NodeBuffer(s).toString( NodeC.BASE64 );
			#else
			return (untyped window.btoa != null) ? untyped window.btoa(s) : haxe.crypto.Base64.encode( Bytes.ofString(s) );
			#end

		#else
		return haxe.crypto.Base64.encode( Bytes.ofString(s) );

		#end
	}

	public static inline function decode( s : String ) : String {
		
		#if php
		return untyped __call__( "base64_decode", s );

	//	#elseif hxssl
	//	return sys.crypto.Base64.decode(s);
		
		#elseif js
			#if nodejs
			return new NodeBuffer( s, NodeC.BASE64 ).toString( NodeC.ASCII );
			#else
			return (untyped window.atob != null) ? untyped window.atob(s) : haxe.crypto.Base64.decode( s ).toString();
			#end

		#else
		return haxe.crypto.Base64.decode( s ).toString();

		#end
	}

	/*
	public static inline function decodeBytes( data : Bytes ) : Bytes {

		#if php
		return Bytes.ofData( untyped __call__( "base64_decode", data.getData() ) );
		
		#elseif js
			#if nodejs
			return Bytes.ofString( new NodeBuffer( b.toString(), NodeC.BASE64 ).toString( NodeC.ASCII ) );
			#else

			#end

		#else
		return haxe.crypto.Base64.decode( data );
		//return new BaseCode( Bytes.ofString( CHARS ) ).decodeBytes( b );
		
		#end
	}
	*/

	/**
		Create a random (base64 compatible) string of given length.
	*/
	public static function random( len : Int = 1, ?chars : String ) : String {
		var n : Null<Int> = null;
		if( chars == null ) {
			chars = haxe.crypto.Base64.CHARS;
			n = haxe.crypto.Base64.CHARS.length-2;
		} else
			n = chars.length;
		var s = new StringBuf();
		for( i in 0...len ) s.add( chars.charAt( Std.random( n ) ) );
		return s.toString();
	}

}
