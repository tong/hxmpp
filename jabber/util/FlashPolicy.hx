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

#if neko
import neko.net.Socket;
#elseif cpp
import cpp.net.Socket;
#elseif nodejs
import js.Node;
typedef Socket = Stream;
#elseif (air&&flash)
import flash.net.Socket;
#elseif (air&&js)
import air.Socket;
#end

class FlashPolicy {
	
	public static function allow( request : String, socket : Socket, host : String, port : Int ) {
		if( request.length == 23 && request.substr(0,22) == "<policy-file-request/>" ) {
			#if (neko||cpp)
			socket.write( '<cross-domain-policy><allow-access-from domain="'+host+'" to-ports="'+port+'"/></cross-domain-policy>'+String.fromCharCode(0) );
			socket.output.flush();
			#elseif nodejs
			socket.write( '<cross-domain-policy><allow-access-from domain="'+host+'" to-ports="'+port+'"/></cross-domain-policy>'+String.fromCharCode(0) );
			#elseif air
			socket.writeUTFBytes( '<cross-domain-policy><allow-access-from domain="'+host+'" to-ports="'+port+'"/></cross-domain-policy>'+String.fromCharCode(0) );
			socket.flush();
			#end
		}
	}
	
}
