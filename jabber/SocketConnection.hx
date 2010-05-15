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
package jabber;

#if flash
import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.ByteArray;
#elseif neko
import neko.net.Host;
import neko.net.Socket;
#elseif php
import php.net.Host;
import php.net.Socket;
#elseif cpp
import cpp.net.Host;
import cpp.net.Socket;
#elseif nodejs
import js.Node;
private typedef Socket = Stream;
#elseif air
import air.Socket;
import air.Event;
import air.IOErrorEvent;
import air.SecurityErrorEvent;
import air.ProgressEvent;
import air.ByteArray;
#end

// TODO
// timeout passing to socketbridge
// js targets buf max size check
// js targets StringBuf performance test
// -1 return aborting/cleanup

class SocketConnection extends jabber.stream.Connection {
	
	public static var defaultBufSize = #if php 65536 #else 128 #end; //TODO php buf
	public static var defaultMaxBufSize = 131072;
	
	public var port(default,null) : Int;
	public var bufSize(default,null) : Int;
	public var maxBufSize(default,null) : Int;
	public var timeout(default,null) : Int;
	
	var socket : Socket;
	#if (flash||air)
	var buf : ByteArray;
	#elseif (neko||php||cpp)
	var reading : Bool;
	var buf : haxe.io.Bytes;
	var bufbytes : Int;
	#elseif (nodejs||JABBER_SOCKETBRIDGE)
	var buf : String;
	//var buf : StringBuf;
	//var bufbytes : Int;
	#end
	
	public function new( host : String, ?port : Int = 5222,
						 ?bufSize : Int,
						 ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host );
		this.port = port;
		this.bufSize = ( bufSize == null ) ? defaultBufSize : bufSize;
		this.maxBufSize = ( maxBufSize == null ) ? defaultMaxBufSize : maxBufSize;
		this.timeout = timeout;
		#if (neko||php||cpp)
		reading = false;
		#end
	}
	
	/*
	function setTimeout( t : Int ) : Int {
		return timeout = ( t <= 0 ) ? 1 : t;
	}
	function setMaxBufSize( t : Int ) : Int {
		return timeout = ( t <= 0 ) ? 1 : t;
	}
	*/
	
	public override function connect() {
		
		#if nodejs
		socket = Node.net.createConnection( port, host );
		#else
		socket = new Socket();
		#end
		
		#if flash10
		socket.timeout = timeout*1000;
		#end
		#if (flash||air)
		buf = new ByteArray();
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
		socket.connect( host, port );
		
		#elseif (neko||cpp||php)
		//TODO socket.setTimeout( timeout );
		buf = haxe.io.Bytes.alloc( bufSize );
		bufbytes = 0;
		socket.connect( new Host( host ), port );
		connected = true;
		__onConnect();
		
		#elseif nodejs
		buf = "";
		//buf = new StringBuf();
		//bufbytes = 0;
		socket.addListener( "connect", sockConnectHandler );
		socket.addListener( "end", sockDisconnectHandler );
		socket.addListener( "error", sockErrorHandler );
		socket.addListener( "drain", sockDrainHandler );
		socket.addListener( "data", sockDataHandler );
		
		#elseif JABBER_SOCKETBRIDGE
		buf = "";
		socket.onConnect = sockConnectHandler;
		socket.onDisconnect = sockDisconnectHandler;
		socket.onError = sockErrorHandler;
		socket.connect( host, port );
		
		#end
	}
	
	public override function disconnect() {
		if( !connected )
			return;
		#if (neko||php||cpp)
		reading = false;
		#end
		connected = false;
		try {
			#if nodejs
			socket.end();
			#else
			socket.close();
			#end
		} catch( e : Dynamic ) {
			__onError( "Error closing socket" );
		}
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			#if (flash||air)
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			#elseif (neko||php||cpp)
			reading = true;
			while( reading  && connected ) {
				readData();
			}
			#elseif JABBER_SOCKETBRIDGE
			socket.onData = sockDataHandler;
			#end
		} else {
			#if (flash||air)
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			#elseif (neko||php||cpp)
			reading = false;
			#elseif JABBER_SOCKETBRIDGE
			socket.onData = null;
			#elseif nodejs
			//TODO check
			socket.removeListener( "data", sockDataHandler );
			#end
		}
		return true;
	}
	
	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		#if (flash||air)
		socket.writeUTFBytes( t ); 
		socket.flush();
		#elseif (neko||php||cpp)
		socket.output.writeString( t );
		socket.output.flush();
		#elseif nodejs
		socket.write( t );
		#elseif JABBER_SOCKETBRIDGE
		socket.send( t );
		#end
		return true;
	}
	
	/*
	public override function reset() {
		trace("rESssET");
		#if (neko||cpp||php)
		buf = haxe.io.Bytes.alloc( bufSize );
		#elseif (nodejs||JABBER_SOCKETBRIDGE)
		buf = "";
		#elseif flash
		buf = new ByteArray();
		#end
	}
	*/
	
	#if (flash||air)

	function sockConnectHandler( e : Event ) {
		connected = true;
		__onConnect();
	}

	function sockDisconnectHandler( e : Event ) {
		connected = false;
		__onDisconnect();
	}
	
	function sockErrorHandler( e : Event ) {
		connected = false;
		__onError( e.type );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		try {
			socket.readBytes( buf, buf.length, e.bytesLoaded );
		} catch( e : Dynamic ) {
			#if JABBER_DEBUG
			//trace(e);
			#end
			return;
		}
		var b = haxe.io.Bytes.ofData( untyped buf );
		if( b.length > maxBufSize )
			throw "Max buffer size reached ("+maxBufSize+")";
		if( __onData(  b, 0, b.length ) > 0 )
			buf = new ByteArray();
		//socket.flush();
	}
	
	#elseif (neko||php||cpp)
	
	function readData() {
		var buflen = buf.length;
		if( bufbytes == buflen ) {
			var nsize = buflen*2;
			if( nsize > maxBufSize ) {
				nsize = maxBufSize;
				if( buflen == maxBufSize  )
					throw "Max buffer size reached ("+maxBufSize+")";
			}
			var buf2 = haxe.io.Bytes.alloc( nsize );
			buf2.blit( 0, buf, 0, buflen );
			buflen = nsize;
			buf = buf2;
		}
		var nbytes = 0;
		nbytes = socket.input.readBytes( buf, bufbytes, buflen-bufbytes );
		bufbytes += nbytes;
		var pos = 0;
		while( bufbytes > 0 ) {
			var nbytes = __onData( buf, pos, bufbytes );
			if( nbytes == 0 ) {
				return;
			}
			pos += nbytes;
			bufbytes -= nbytes;
		}
		if( reading && pos > 0 )
			buf = haxe.io.Bytes.alloc( bufSize );
		//buf.blit( 0, buf, pos, bufbytes );
	}
	
	#elseif (nodejs||JABBER_SOCKETBRIDGE)
	
	#if nodejs
	
	function sockDrainHandler() {
		trace("NODEJS:socket drain");
	}
	
	#end
	
	function sockConnectHandler() {
		connected = true;
		__onConnect();
	}
	
	function sockDisconnectHandler() {
		connected = false;
		__onDisconnect();
	}
	
	function sockErrorHandler( e : String ) {
		connected = false;
		__onError( e );
	}
	
	function sockDataHandler( t : String ) {
		/*
		var len = t.length;
		var s = buf.toString()+t;
		if( s.length > maxBufSize ) {
			#if JABBER_DEBUG
			trace( "Max socket buffer size reached ("+maxBufSize+")" );
			#end
			throw "Max socket buffer size reached ("+maxBufSize+")";
		}
		var r = __onData( haxe.io.Bytes.ofString( s ), 0, bufbytes+len );
		if( r == 0 ) {
			buf.add( t );
			bufbytes += len;
		} else {
			buf = new StringBuf();
			bufbytes = 0;
		}
		*/
		var s = buf+t;
		if( s.length > maxBufSize ) {
			#if JABBER_DEBUG
			trace( "Max socket buffer size reached ("+maxBufSize+")" );
			#end
			throw "Max socket buffer size reached ("+maxBufSize+")";
		}
		var r = __onData( haxe.io.Bytes.ofString( s ), 0, s.length );
		buf = ( r == 0 ) ? s : ""; 
	}
	
	#end
	
}

#if JABBER_SOCKETBRIDGE

/**
	Socketbridge socket.
*/
class Socket {
	
	public dynamic function onConnect() : Void;
	public dynamic function onDisconnect() : Void;
	public dynamic function onData( d : String ) : Void;
	public dynamic function onError( e : String ) : Void;
	
	public var id(default,null) : Int;
	//var timeout : Int;
	
	public function new() {
		var id : Int = SocketBridgeConnection.createSocket( this );
		if( id < 0 )
			throw "Error creating socket on socket bridge";
		this.id = id;
	}
	
	public function connect( host : String, port : Int ) {
		untyped js.Lib.document.getElementById( SocketBridgeConnection.bridgeId ).connect( id, host, port );
	}
	
	public function close() {
		untyped js.Lib.document.getElementById( SocketBridgeConnection.bridgeId ).disconnect( id );
	}
	
	/*
	public function destroy() {
		var _s = untyped js.Lib.document.getElementById( SocketBridgeConnection.bridgeId ).destroy( id );
	}
	*/
	
	public function send( d : String ) {
		untyped js.Lib.document.getElementById( SocketBridgeConnection.bridgeId ).send( id, d );
	}
	
}

/**
*/
class SocketBridgeConnection {
	
	public static var defaultDelay = 300;
	public static var bridgeId(default,null) : String;
	
	static var sockets : IntHash<Socket>;
	static var initialized = false;
	
	public static function init( id : String ) {
		if( initialized )
			throw "Socketbridge already initialized";
		bridgeId = id;
		sockets = new IntHash();
		initialized = true;
	}
	
	public static function initDelayed( id : String, cb : Void->Void, ?delay : Int ) {
		if( delay == null || delay <= 0 ) delay = defaultDelay;
		init( id );
		haxe.Timer.delay( cb, delay );
	}
	
	
	public static function createSocket( s : Socket ) {
		var id : Int = -1;
		try {
			id = untyped js.Lib.document.getElementById( bridgeId ).createSocket();
		} catch( e : Dynamic ) {
			return -1;
		}
		sockets.set( id, s );
		return id;
	}
	
	/*
	public static function destroySocket( id : Int ) {
		var removed = untyped js.Lib.document.getElementById( bridgeId ).destroySocket( id );
		if( removed ) {
			var s =  sockets.get( id );
			sockets.remove( id );
			s = null;
		}
	}
	
	public function destroyAllSockets() {}
	
	*/
	
	static function handleConnect( id : Int ) {
		var s = sockets.get( id );
		s.onConnect();
	}
	
	static function handleDisonnect( id : Int ) {
		var s = sockets.get( id );
		s.onDisconnect();
	}
	
	static function handleError( id : Int, e : String ) {
		var s = sockets.get( id );
		s.onError( e );
	}
	
	static function handleData( id : Int, d : String ) {
		var s = sockets.get( id );
		s.onData( d );
	}
	
}

#end // JABBER_SOCKETBRIDGE
