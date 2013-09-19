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

#if neko

class RTPTransport extends Transport {
	
	public var ip(default,null) : String;
	public var port(default,null) : Int;
	
	function new( ip : String, port : Int ) {
		super();
		this.ip = ip;
		this.port = port;
	}
	
	public override function toXml() : Xml {
		//TODO
		/*
		<candidate component='1' foundation='1'
		generation='0' id='purple6bbb39b1'
		ip='192.168.0.110' network='0'
		port='54544' priority='2013266431'
		protocol='udp' type='host'/>
	*/
		var x = Xml.createElement( 'candidate' );
		x.set( 'component', Std.string(1) );
		x.set( 'foundation', Std.string(1) );
		x.set( 'generation', Std.string(0) );
		x.set( 'id', jabber.util.SHA1.encode(Date.now().toString()) );
		x.set( 'ip', ip );
		x.set( 'port', Std.string( port ) );
		x.set( 'priority', Std.string(3453466) );
		x.set( 'protocol', 'udp' );
		x.set( 'type', 'host' );
		x.set( 'network', Std.string(0) );
		return x;
	}
	
}

#end // neko
