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
	
	public static inline function encode( s : String ) : String {
		#if php
		return untyped __call__( "sha1", s );
		#elseif nodejs
		var h = Node.crypto.createHash( "sha1" );
		h.update( s );
		return h.digest( Node.HEX );
		#else
		return haxe.SHA1.encode(s);
		#end
	}
	
}

/* 
#else
//typedef SHA1 = haxe.SHA1;
class SHA1 {
	public static function encode( s : String ) : String {
		return haxe.SHA1.encode(s);
	}
}

#end
*/