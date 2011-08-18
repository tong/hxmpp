/*
 *	This file is part of HXMPP.
 *	Copyright (c)2010 http://www.disktree.net
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

import flash.external.ExternalInterface;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;

private class Socket extends flash.net.Socket {
	public var id(default,null) : UInt;
	public function new( id : UInt ) {
		super();
		this.id = id;
	}
}

class FlashSocketBridge{
	
	var ctx : String;
	var sockets : IntHash<Socket>;
	
	var outputInterval : Int;
	var queue : Array<{id:Int,data:String}>;
	var timer : haxe.Timer;
	
	public function new( ?ctx : String, outputInterval : Int = 1 ) {
		this.ctx = ( ctx != null ) ? ctx : "jabber.SocketConnection";
		this.outputInterval = outputInterval;
	}
	
	public function init() {
		if( !ExternalInterface.available )
			throw "External interface not available";
		sockets = new IntHash();
		ExternalInterface.addCallback( "createSocket", createSocket );
		ExternalInterface.addCallback( "destroySocket", destroySocket );
		ExternalInterface.addCallback( "connect", connect );
		ExternalInterface.addCallback( "disconnect", disconnect );
		ExternalInterface.addCallback( "send", send );
		//ExternalInterface.addCallback( "destroy", destroy );
		ExternalInterface.addCallback( "destroyAll", destroyAll );
		queue = new Array();
		timer = new haxe.Timer( outputInterval );
		timer.run = onTimer;
	}
	
	function createSocket( ___secure : Bool, __legacy__ : Bool, timeout : Int = -1 ) : Int {
		var id = Lambda.count( sockets );
		var s = new Socket( id );
		#if flash10
		if( timeout != -1 ) s.timeout = timeout*1000;
		#end
		sockets.set( id, s );
		s.addEventListener( Event.CONNECT, sockConnectHandler );
		s.addEventListener( Event.CLOSE, sockDisconnectHandler );
		s.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		s.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
		s.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		return id;
	}
	
	function destroySocket( id : Int ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		if( s.connected ) s.close();
		sockets.remove( s.id );
		s = null;
		return true;
	}
	
	function destroyAll() {
		for( s in sockets ) {
			s.close();
			s = null;
		}
		sockets = new IntHash();
	}
	
	function connect( id : Int, host : String, port : Int, ?timeout : Int = -1 ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		#if flash10
		if( timeout > 0 ) s.timeout = timeout;
		#end
		s.connect( host, port );
		return true;
	}
	
	function disconnect( id : Int ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		s.close();
		return true;
	}
	
	function send( id : Int, data : String ) : Bool {
		if( !sockets.exists( id ) )
			return false;
		var s = sockets.get( id );
		s.writeUTFBytes( data ); 
		s.flush();
		return true;
	}
	
	function sockConnectHandler( e : Event ) {
		ExternalInterface.call( ctx+".handleConnect", e.target.id );
	}

	function sockDisconnectHandler( e : Event ) {
		ExternalInterface.call( ctx+".handleDisconnect", e.target.id, null );
	}
	
	function sockErrorHandler( e : Event ) {
		ExternalInterface.call( ctx+".handleDisconnect", e.target.id, e.type );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		//ExternalInterface.call( ctx+".handleData", e.target.id, e.target.readUTFBytes( e.bytesLoaded ) );
		queue.push( { id : e.target.id, data : e.target.readUTFBytes( e.bytesLoaded ) } );
	}
	
	function onTimer() {
		if( queue.length > 0 ) {
			var n = queue.shift();
			ExternalInterface.call( ctx+".handleData", n.id, n.data );
		}
	}

}
