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

import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.NetStream;

@:require(flash) class RTMPTransport extends Transport {
	
	public var name(default,null) : String;
	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var id(default,null) : String;
	public var ns(default,null) : NetStream;
	
	var nc : NetConnection;
	
	function new( name : String, host : String, port : Int = 1935, id : String ) {
		super();
		this.name = name;
		this.host = host;
		this.port = port;
		this.id = id;
	}
	
	public override function connect() {
		nc = new NetConnection();
		nc.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
		try nc.connect( "rtmp://"+host+":"+port ) catch( e : Dynamic ) {
			__onFail( e );
		}
	}
	
	public override function close() {
		if( ns != null ) ns.close();
		if( nc != null && nc.connected ) nc.close();
	}
	
	public override function toXml() : Xml {
		var x = Xml.createElement( "candidate" );
		x.set( "name", name );
		x.set( "host", host );
		x.set( "port", Std.string( port ) );
		x.set( "id", id );
		return x;
	}
	
	function netStatusHandler( e : NetStatusEvent ) {
		if( StringTools.startsWith( e.info.code, "NetStream.Buffer" ) )
			return;
		switch( e.info.code ) {
		case "NetConnection.Connect.Failed" :
			//connected = false;
			__onFail( e.info.code );
		case "NetConnection.Connect.Success" :
			ns = new NetStream( nc );
			ns.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			//connected = true;
			__onConnect();
		case "NetConnection.Connect.Closed" :
			//connected = false;
			__onDisconnect();
		}
	}
	
}
