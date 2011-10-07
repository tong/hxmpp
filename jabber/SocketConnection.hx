/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009-2010 http://www.disktree.net
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

import haxe.io.Bytes;

#if (neko||php||cpp||rhino)

#if neko
import neko.net.Host;
import neko.net.Socket;
#elseif php
import php.net.Host;
import php.net.Socket;
#elseif cpp
import cpp.net.Host;
import cpp.net.Socket;
#elseif rhino
import js.net.Host;
import js.net.Socket;
#end

class SocketConnection extends jabber.stream.SocketConnectionBase {
		
	public function new( host : String,
						 port : Int = #if JABBER_COMPONENT 5275 #else 5222 #end,
						 secure : Bool = #if (neko||cpp||air) false #else true #end,
						 ?bufsize : Int, ?maxbufsize : Int,
						 timeout : Int = 10 ) {
		
		super( host, port, secure, bufsize, maxbufsize, timeout );
		#if (JABBER_DEBUG && (neko||cpp||air) )
		if( secure ) {
			trace( "StartTLS not implemented, use jabber.SecureSocketConnection for legacy TLS on port 5223", "warn" );
			this.secure = false;
		}
		#end
	}
	
	public override function connect() {
		socket = new Socket();
		buf = Bytes.alloc( bufsize );
		bufpos = 0;
		try socket.connect( new Host( host ), port ) catch( e : Dynamic ) {
			__onDisconnect( e );
			return;
		}
		connected = true;
		__onConnect();
	}
	
	public override function setSecure() {
		#if (neko||cpp)
		throw "startTLS not implemented";
		#elseif php
		try {
			secured = untyped __call__( 'stream_socket_enable_crypto', socket.__s, true, 1 );
		} catch( e : Dynamic ) {
			__onSecured( e );
			return;
		}
		__onSecured( null );
		#end
	}
	
	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		try {
			socket.output.writeString( t );
			socket.output.flush();
		} catch(e:Dynamic) {
		}
		return true;
	}
	
	public override function writeBytes( t : Bytes ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.output.write( t );
		socket.output.flush();
		return true;
	}
}

#elseif ( flash && TLS )

import flash.utils.ByteArray;
import tls.controller.SecureSocket;
import tls.event.SecureSocketEvent;
import tls.valueobject.SecurityOptionsVO;

class SocketConnection extends jabber.stream.SocketConnectionBase {
	
	public function new( host : String, port : Int = 5222, secure : Bool = true,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, secure, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		socket = new SecureSocket();
		socket.addEventListener( SecureSocketEvent.ON_CONNECT, sockConnectHandler );
		socket.addEventListener( SecureSocketEvent.ON_SECURE_CHANNEL_ESTABLISHED, secureChannelEstablished );
		socket.addEventListener( SecureSocketEvent.ON_CLOSE, sockDisconnectHandler );
		socket.addEventListener( SecureSocketEvent.ON_ERROR, sockErrorHandler );
		socket.connect( host, port );
	}
	
	public override function disconnect() {
		if( !connected )
			return;
		connected = false;
		try socket.close() catch( e : Dynamic ) {
			__onDisconnect( e );
		}
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			socket.addEventListener( SecureSocketEvent.ON_PROCESSED_DATA, socketDataHandler );
		} else {
			socket.removeEventListener( SecureSocketEvent.ON_PROCESSED_DATA, socketDataHandler );
		}
		return true;
	}
	
	public override function write( t : String ) : Bool {
		socket.sendString( t );
		return true;
	}
	
	public override function writeBytes( bytes : Bytes ) : Bool {
		socket.sendByteArray( bytes.getData(), 0, bytes.length );
		return true;
	}
	
	public override function setSecure() {
		socket.startSecureSupport( SecurityOptionsVO.getDefaultOptions( SecurityOptionsVO.SECURITY_TYPE_TLS ) );
	}
	
	function sockConnectHandler( e : SecureSocketEvent ) {
		connected = true;
		__onConnect();
	}
	
	function sockDisconnectHandler( e : SecureSocketEvent ) {
		connected = false;
		__onDisconnect(null);
	}
	
	function secureChannelEstablished( e : SecureSocketEvent ) {
		secured = true;
		__onSecured( null );
	}
	
	function sockErrorHandler( e : SecureSocketEvent ) {
		connected = false;
		__onDisconnect( e.toString() );
	}
	
	function socketDataHandler( e : SecureSocketEvent ) {
		__onData( Bytes.ofData( e.rawData ) );
	}
}

#elseif flash

import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.ByteArray;

class SocketConnection extends jabber.stream.SocketConnectionBase {
	
	//#if air
	public var socket(default,null) : Socket;
	//#end
	
	public function new( host : String, port : Int = 5222, secure : Bool = false,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, false, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		socket = new Socket();
		#if flash10
		socket.timeout = timeout*1000;
		#end
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
		socket.connect( host, port );
	}
	
	public override function disconnect() {
		if( !connected )
			return;
		connected = false;
		try socket.close() catch( e : Dynamic ) {
			__onDisconnect( e );
		}
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		} else {
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		}
		return true;
	}
	
	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.writeUTFBytes( t ); 
		socket.flush();
		return true;
	}
	
	public override function writeBytes( t : Bytes ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.writeBytes( t.getData() ); 
		socket.flush();
		return true;
	}
	
	function sockConnectHandler( e : Event ) {
		connected = true;
		__onConnect();
	}
	
	function sockDisconnectHandler( e : Event ) {
		connected = false;
		__onDisconnect(null);
	}
	
	function sockErrorHandler( e : Event ) {
		connected = false;
		__onDisconnect( e.type );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		var d = new ByteArray();
		socket.readBytes( d, 0, Std.int( e.bytesLoaded ) );
		__onData( haxe.io.Bytes.ofData( d )  );
		/*
		var d = new ByteArray();
		try socket.readBytes( d, 0, Std.int(e.bytesLoaded) ) catch( e : Dynamic ) {
			#if JABBER_DEBUG trace( e, "error" ); #end
			return;
		}
		trace(d.length);
		__onData(  haxe.io.Bytes.ofData( d )  );
		*/
	}
}
#elseif (js&&droid)

class SocketConnection extends jabber.stream.SocketConnectionBase {
	public function new( host : String, port : Int = 5222 ) {
		super( host, port, false );
	}
}

#elseif (js&&air)
import air.Socket;
import air.ByteArray;
import air.Event;
import air.IOErrorEvent;
import air.ProgressEvent;
import air.SecurityErrorEvent;

class SocketConnection extends jabber.stream.SocketConnectionBase {
	
	public function new( host : String, port : Int = 5222, secure : Bool = false,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, false, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		socket = new Socket();
		socket.timeout = timeout*1000;
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
		socket.connect( host, port );
	}
	
	public override function disconnect() {
		if( !connected )
			return;
		connected = false;
		try socket.close() catch( e : Dynamic ) {
			__onDisconnect( e );
			return;
		}
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		} else {
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		}
		return true;
	}
	
	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		try {
			socket.writeUTFBytes( t );
			socket.flush();
		} catch(e:Dynamic) {
			#if JABBER_DEBUG trace( e, "error" ); #end
			return false;
		}
		return true;
	}
	
	public override function writeBytes( t : Bytes ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		try {
			socket.writeBytes( t.getData() ); 
			socket.flush();
		} catch(e:Dynamic) {
			#if JABBER_DEBUG trace( e, "error" ); #end
			return false;
		}
		return true;
	}
	
	//??
	/*
	public override function reset() {
		#if JABBER_DEBUG trace('clearing socket buffer','info'); #end
	}
	*/
	
	function sockConnectHandler( e : Event ) {
		connected = true;
		__onConnect();
	}
	
	function sockDisconnectHandler( e : Event ) {
		connected = false;
		__onDisconnect(null);
	}
	
	function sockErrorHandler( e : Event ) {
		connected = false;
		__onDisconnect( e.type );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		var d = new ByteArray();
		try socket.readBytes( d, 0, Std.int(e.bytesLoaded) ) catch( e : Dynamic ) {
			#if JABBER_DEBUG trace(e,"error"); #end
			return;
		}
		__onData(  haxe.io.Bytes.ofData( d )  );
	}
}

#elseif (js&&nodejs)

import js.Node;

private typedef Socket = Stream;

class SocketConnection extends jabber.stream.SocketConnectionBase {
	
	public var socket(default,null) : Socket;
	
	public function new( host : String, port : Int = 5222, secure : Bool = true,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, secure, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		createConnection();
		socket.on( Node.STREAM_END, sockDisconnectHandler );
		socket.on( Node.STREAM_ERROR, sockErrorHandler );
		socket.on( Node.STREAM_DATA, sockDataHandler );
	}
	
	public override function disconnect() {
		if( !connected )
			return;
		try socket.end() catch( e : Dynamic ) {
			__onDisconnect( e );
		}
	}
	
	public override function setSecure() {
		//TODO 'setSecure' got removed from node.js
		trace("SET SECURE_________________________________");
		// hmm? TypeError: Object #<a Stream> has no method 'setSecure' ??????????
		//socket.on( Node.STREAM_SECURE, sockSecureHandler );
		//trace( socket.getPeerCertificate() );
		socket.setSecure(  );
	}
	
	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.write( t );
		return true;
	}
	
	public override function writeBytes( t : Bytes ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.write( t.getData() ); 
		return true;
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( !yes )
			socket.removeListener( Node.STREAM_DATA, sockDataHandler );
		return true;
	}
	
	function createConnection() {
		socket = Node.net.createConnection( port, host );
		socket.setEncoding( Node.UTF8 );
		//socket = Node.tls.connect( port, host, null, sockConnectHandler );
		socket.on( Node.STREAM_CONNECT, sockConnectHandler );
	}
	
	function sockConnectHandler() {
		connected = true;
		__onConnect();
	}
	
	function sockDisconnectHandler() {
		connected = false;
		__onDisconnect(null);
	}
	
	function sockErrorHandler( e : String ) {
		connected = false;
		__onDisconnect( e );
	}
	
	function sockSecureHandler() {
		secured = true;
		__onSecured( null );
	}
	
	//TODO use raw bytes
	function sockDataHandler( t : String ) {
		/*
		var s = buf+t;
		if( s.length > maxBufSize )
			throw "max socket buffer size reached ["+maxBufSize+"]";
		var r = __onData( Bytes.ofString( s ), 0, s.length );
		buf = ( r == 0 ) ? s : "";
		*/
		__onString( t );
	}
	
}

#elseif (js&&JABBER_SOCKETBRIDGE)

import jabber.stream.SocketConnection;

class SocketConnection extends jabber.stream.SocketConnectionBase {

	public function new( host : String, ?port : Int = 5222, secure = true, timeout : Int = 10 ) {
		super( host, port, secure, null, null, timeout );
	}
	
	public override function connect() {
		if( !SocketConnection.initialized )
			throw "flash socketbridge not initialized";
		socket = new Socket( secure, timeout );
		socket.onConnect = sockConnectHandler;
		socket.onDisconnect = sockDisconnectHandler;
		socket.onSecured = sockSecuredHandler;
		socket.connect( host, port, timeout*1000 );
	}
	
	public override function disconnect() {
		if( !connected )
			return;
		connected = false;
		try socket.close() catch( e : Dynamic ) {
			__onDisconnect( e );
		}
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		socket.onData = yes ? sockDataHandler : null;
		return true;
	}
	
	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.send( t );
		return true;
	}
	
	public override function setSecure() {
		socket.setSecure();
	}
	
	function sockConnectHandler() {
		connected = true;
		__onConnect();
	}
	
	function sockDisconnectHandler( ?e : String ) {
		connected = false;
		__onDisconnect( e );
	}
	
	function sockSecuredHandler() {
		secured = true;
		__onSecured( null );
	}
	
	function sockDataHandler( t : String ) {
		__onString( t );
	}
	
	///// Flash socketbridge connection(s) ->
		
	static function __init__() {
		initialized = false;
	}
	
	/** The id of the html element holding the swf */
	public static var id(default,null) : String;
	/** Reference to the swf itself */
	public static var swf(default,null) : Dynamic;
	/** Indicates if the socketbridge stuff is initialized */
	public static var initialized(default,null) : Bool;
	
	static var sockets : IntHash<Socket>;
	
	public static function init( id : String, cb : String->Void, ?delay : Int = 0 ) {
		if( initialized ) {
			#if JABBER_DEBUG trace( 'socketbridge already initialized ['+id+']', 'warn' ); #end
			cb( 'socketbridge already initialized ['+id+']' );
			return;
		}
		var _init = function(){
			swf = js.Lib.document.getElementById( id );
			if( swf == null ) {
				cb( 'socketbridge swf not found ['+id+']' );
				return;
			}
			sockets = new IntHash();
			initialized = true;
			cb(null);
		}
		if( delay > 0 ) haxe.Timer.delay( _init, delay ) else _init();
	}
	
	public static function createSocket( s : Socket, secure : Bool, timeout : Int ) {
		var id : Int = -1;
		try id = swf.createSocket( secure, false, timeout ) catch( e : Dynamic ) {
			#if JABBER_DEBUG trace(e,"error"); #end
			return -1;
		}
		sockets.set( id, s );
		return id;
	}
	
	static function handleConnect( id : Int ) {
		sockets.get( id ).onConnect();
	}
	
	static function handleDisconnect( id : Int, e : String ) {
		sockets.get( id ).onDisconnect( e );
	}
	
	static function handleData( id : Int, d : String ) {
		sockets.get( id ).onData( d );
	}
	
	static function handleSecure( id : Int ) {
		sockets.get( id ).onSecured();
	}
}

#end
