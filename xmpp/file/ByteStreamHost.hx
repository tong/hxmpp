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
package xmpp.file;

class ByteStreamHost {
	
	public var jid : String;
	public var host : String;
	public var zeroconf : String;
	public var port : Null<Int>;
	
	public function new( jid : String , ?host : String, ?port : Null<Int>, ?zeroconf : String ) {
		this.jid = jid;
		this.host = host;
		this.port = port;
		this.zeroconf = zeroconf;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "streamhost" );
		x.set( "jid", jid );
		if( host != null ) x.set( "host", host );
		if( port != null ) x.set( "port", Std.string( port ) );
		if( zeroconf != null ) x.set( "zeroconf", zeroconf );
		return x;
	}
	
	public static function parse( x : Xml ) : ByteStreamHost {
		var port = x.get( "port" );
		return new ByteStreamHost( x.get( "jid" ),
								   x.get( "host" ),
								   ( port != null ) ? Std.parseInt( port ) : null,
								   x.get( "zeroconf" ) );
	}
	
}
