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

#if nodejs
import js.Node;
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
		
		//TODO
		//#if neko
		//return new String( base_encode( make_sha1( untyped t.__s ), untyped hex_chr.__s ) );
		//#elseif nodejs
		
		#if nodejs
		var h = js.Node.crypto.createHash( "sha1" );
		h.update( s );
		return h.digest( js.Node.HEX );
		
		#elseif php
		return untyped __call__( "sha1", s );
		
		#else
		return haxe.SHA1.encode(s);
		
		#end
	}
	
}
