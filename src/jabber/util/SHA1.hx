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

#if (js && nodejs) import js.Node;
#end

class SHA1 {
	
	/*
	#if neko
	static var base_encode = neko.Lib.load("std","base_encode",2);
	static var make_sha1 = neko.Lib.load("std","make_sha1",3);
	static inline var hex_chr = "0123456789abcdef";
	#end
	*/
	
	public static inline function encode( s : String ) : String {
		
		//#if neko
		//return new String( base_encode( make_sha1( untyped t.__s ), untyped hex_chr.__s ) );
		
		#if php
		return untyped __call__( "sha1", s );
		
		#elseif (hxssl&&hxmpp_hxssl_crypto)
		return sys.crypto.SHA1.encode(s);
		
		#elseif (js&&nodejs)
		var h = js.Node.crypto.createHash( "sha1" );
		h.update( s );
		return h.digest( NodeC.HEX );
		
		#else
		return haxe.crypto.Sha1.encode(s);

		#end
	}
	
}
