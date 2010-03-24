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
import flash.net.NetConnection;
import flash.net.NetStream;

//rtmpt://red5.jivesoftware.org:9090/jingle

/**
	flash.
	RTMP jingle transport base.
*/
class RTMPTransport {
	
	public var __onFail : Void->Void;
	public var __onConnect : Void->Void;
	public var __onDisconnect : Void->Void;
	
	public var connected(default,null) : Bool;
	public var name(default,null) : String;
	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var id(default,null) : String;
	public var nc(default,null) : NetConnection;
	public var ns(default,null) : NetStream;
	public var url(getURL,null) : String;
	
	function new( name : String, host : String, port : Int, id : String ) {
		this.name = name;
		this.host = host;
		this.port = port;
		this.id = id;
		connected = false;
	}
	
	public function connect() {
		nc = new NetConnection();
		nc.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
		try { //TODO move into using class
			nc.connect( getURL() );
		} catch( e : Dynamic ) {
			__onFail();
		}
	}
	
	function getURL() : String {
		return "rtmp://"+host+":"+port;
	}
	
	public function close() {
		if( ns != null ) ns.close();
		if( nc != null ) nc.close();
	}
	
	/*
	public function ping() {
		//TODO
	}
	*/
	
	public function toString() : String {
		return Type.getClassName( Type.getClass( this ) )+"("+name+","+host+","+port+","+id+")";
	}
	
	function netStatusHandler( e : NetStatusEvent ) {
		if( StringTools.startsWith( e.info.code, "NetStream.Buffer" ) )
			return;
		switch( e.info.code ) {
		case "NetConnection.Connect.Failed" :
			//cleanup();
			connected = false;
			__onFail();
		case "NetConnection.Connect.Closed" :
			//cleanup();
			connected = false;
			__onDisconnect();
		case "NetConnection.Connect.Success" :
			ns = new NetStream( nc );
			ns.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			connected = true;
			__onConnect();
		}
	}
	
}

#end // flash
