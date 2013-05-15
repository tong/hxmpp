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

#if js

import js.html.ArrayBuffer;
import js.html.Uint8Array;

class ArrayBufferUtil {
	
	/**
		str2ab
	*/
	public static function toArrayBuffer( t : String ) : ArrayBuffer {
		//var b = new ArrayBuffer( t.length*2 ); // 2 bytes for each char
		//var v = new Uint16Array( b );
		var b = new ArrayBuffer( t.length );
		var v = new Uint8Array( untyped b );
		for( i in 0...t.length )
			v[i] = t.charCodeAt( i );
		return b;
	}
	
	/**
		ab2str
	*/
	public static function toString( buf : ArrayBuffer ) : String {
		//return untyped __js__( 'String.fromCharCode.apply(null,new Uint8Array(buf))' );
		var v = new Uint8Array( untyped buf );
		var s = "";
		for( i in 0...v.length )
			s += String.fromCharCode( v[i] );
		return s;
	}
	
	/*
	public static function toArrayBuffer( t : String, cb : ArrayBuffer->Void ) {
		var bb = new BlobBuilder();
		bb.append(t);
		var f = new FileReader();
		f.onload = function(e) {
			cb(e.target.result);
		}
		f.readAsArrayBuffer(bb.getBlob());
	}
	
	public static function toString( b : ArrayBuffer, cb : String->Void ) {
		var bb = new BlobBuilder();
		bb.append(b);
		var f = new FileReader();
		f.onload = function(e) {
			cb(e.target.result);
		}
		f.readAsText(bb.getBlob());
	}
	*/
	
}

#end
