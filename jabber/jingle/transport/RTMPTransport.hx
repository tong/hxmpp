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
package jabber.jingle.transport;

#if flash

import flash.events.NetStatusEvent;

/**
	flash9
	RTMP jingle transport base.
*/
class RTMPTransport {
	
	public var __onFail : Void->Void;
	public var __onConnect : Void->Void;
	public var __onDisconnect : Void->Void;
	
	public var name(default,null) : String;
	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var id(default,null) : String;
	public var ns(default,null) : flash.net.NetStream;
	public var nc(default,null) : flash.net.NetConnection;
	
	function new( name : String, host : String, port : Int, id : String ) {
		this.name = name;
		this.host = host;
		this.port = port;
		this.id = id;
	}
	
	public function connect() {
		nc = new flash.net.NetConnection();
		nc.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
		nc.connect( "rtmp://"+host+":"+port );
	}
	
	public function close() {
		ns.close();
		nc.close();
	}
	
	//TODO public function ping() {
	
	function netStatusHandler( e : NetStatusEvent ) {
		if( StringTools.startsWith( e.info.code, "NetStream.Buffer" ) )
			return;
		trace(e.info.code);
		switch( e.info.code ) {
		case "NetConnection.Connect.Failed" :
			__onFail();
		case "NetConnection.Connect.Closed" :
			__onDisconnect();
		case "NetConnection.Connect.Success" :
			ns = new flash.net.NetStream( nc );
			ns.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			__onConnect();
		}
	}
	
}

#end // flash
