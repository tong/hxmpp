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
package jabber.jingle.io;

#if (neko||cpp)
import sys.net.Socket;
#end
#if flash
import flash.net.Socket;
#elseif nodejs
import js.Node;
private typedef Socket = Stream;
#end

class ByteStreamTransport extends Transport {
	
	public var __onComplete : Void->Void;
	
	public var host(default,null) : String;
	public var port(default,null) : Int;
	
	var socket : Socket;
	var bufsize : Int;
	
	public function new( host : String, port : Int, bufsize : Int = 4096 ) {
		super();
		this.host = host;
		this.port = port;
		this.bufsize = bufsize;
	}
	
	public override function toXml() : Xml {
		var x = Xml.createElement( 'candidate' ); // TODO out of spec ..should be 'streamhost'
		x.set( 'host', host );
		x.set( 'port', Std.string( port )  );
		return x;
	}
	
}
