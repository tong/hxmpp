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

class SocketConnection extends jabber.stream.SocketConnection {
		
	public function new( host : String,
						 port : Int = #if JABBER_COMPONENT 5275 #else 5222 #end,
						 secure : Bool = #if (neko||cpp||air) false #else true #end,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, secure, bufSize, maxBufSize, timeout );
		#if (neko||cpp)
		#if JABBER_DEBUG
		if( secure ) {
			trace( "StartTLS not implemented" );
			trace( "Use jabber.SecureSocketConnection for legacy TLS on port 5223" );
			this.secure = false;
		}
		#end
		#end
	}
	
	public override function connect() {
		socket = new Socket();
		buf = haxe.io.Bytes.alloc( bufSize );
		bufbytes = 0;
		try socket.connect( new Host( host ), port ) catch( e : Dynamic ) {
			__onDisconnect( e );
			return;
		}
		connected = true;
		__onConnect();
	}
	
	public override function setSecure() {
		#if (neko||cpp)
		throw new jabber.error.Error( "StartTLS not implemented" );
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
		socket.output.writeString( t );
		socket.output.flush();
		return true;
	}
	
	/*
	public override function writeBytes( t : haxe.io.Bytes ) : Bool {
		socket.output.write( t );
		socket.output.flush();
		trace("wWW");
		return true;
	}
	*/
}

#elseif flash

#if TLS
import flash.utils.ByteArray;
import tls.controller.SecureSocket;
import tls.event.SecureSocketEvent;
import tls.valueobject.SecurityOptionsVO;

class SocketConnection extends jabber.stream.SocketConnection {
		
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
	
	public override function setSecure() {
		socket.startSecureSupport( SecurityOptionsVO.getDefaultOptions( SecurityOptionsVO.SECURITY_TYPE_TLS ) );
	}
	
	function sockConnectHandler( e : SecureSocketEvent ) {
		trace(e);
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
		var b = haxe.io.Bytes.ofData( e.rawData );
		if( b.length > maxBufSize ) {
			throw new jabber.error.Error( "max buffer size reached ["+maxBufSize+"]" );
		}
		__onData( b, 0, b.length );
		//TODO
		//if( __onData(  b, 0, b.length ) > 0 )
		//	buf = new ByteArray();
	}
}

#else //!TLS->

import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.ByteArray;

class SocketConnection extends jabber.stream.SocketConnection {
	
	var buf : ByteArray;
	#if air
	var socket : Socket;
	#end
	
	public function new( host : String, port : Int = 5222, secure : Bool = false,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, false, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		socket = new Socket();
		#if flash10 socket.timeout = timeout*1000; #end
		buf = new ByteArray();
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
	
	/*
	public override function writeBytes( t : haxe.io.Bytes ) : Bool {
		socket.writeBytes( t.getData() ); 
		socket.flush();
		trace("www");
		return true;
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
		socket.readBytes( buf, buf.length, Std.int(e.bytesLoaded) );
		var b = haxe.io.Bytes.ofData( buf );
		if( b.length > maxBufSize )
			throw new jabber.error.Error( "max buffer size reached ["+maxBufSize+"]" );
		if( __onData(  b, 0, b.length ) > 0 )
			buf = new ByteArray();
		//socket.flush();
	}
}
#end

#elseif js

#if air
import air.Socket;
import air.ByteArray;
import air.Event;
import air.IOErrorEvent;
import air.ProgressEvent;
import air.SecurityErrorEvent;

class SocketConnection extends jabber.stream.SocketConnection {
	
	var buf : ByteArray;
	
	public function new( host : String, port : Int = 5222, secure : Bool = false,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, false, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		buf = new air.ByteArray();
		socket = new Socket();
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
			trace(e);
			__onError( "Error closing socket" );
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
		socket.writeUTFBytes( t ); 
		socket.flush();
		return true;
	}
	
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
		try socket.readBytes( buf, buf.length, e.bytesLoaded ) catch( e : Dynamic ) {
			#if JABBER_DEBUG trace(e); #end
			return;
		}
		var b = haxe.io.Bytes.ofData( untyped buf ); //TODO
		if( b.length > maxBufSize )
			throw new jabber.error.Error( "max buffer size reached ["+maxBufSize+"]" );
		if( __onData(  b, 0, b.length ) > 0 )
			buf = new ByteArray();
		//socket.flush();
	}
}

#elseif nodejs

import js.Node;

class SocketConnection extends jabber.stream.SocketConnection {
	
	var buf : String;
	
	public function new( host : String, port : Int = 5222, secure : Bool = true,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, secure, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		buf = "";
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
		//TODO
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
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( !yes )
			socket.removeListener( Node.STREAM_DATA, sockDataHandler );
		return true;
	}
	
	function createConnection() {
		socket = Node.net.createConnection( port, host );
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
	
	//TODO use bytes (no compression + stuff otherwise)
	function sockDataHandler( t : String ) {
		var s = buf+t;
		if( s.length > maxBufSize )
			throw new jabber.error.Error( "max socket buffer size reached ["+maxBufSize+"]" );
		var r = __onData( haxe.io.Bytes.ofString( s ), 0, s.length );
		buf = ( r == 0 ) ? s : "";
	}
	
}


#elseif JABBER_SOCKETBRIDGE

import jabber.stream.SocketConnection;

class SocketConnection extends jabber.stream.SocketConnection {

	var buf : StringBuf;
	
	public function new( host : String,
						 ?port : Int = 5222,
						 secure = true,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, secure, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		if( !SocketConnection.initialized )
			throw new jabber.error.Error( "socketbridge not initialized" );
		buf = new StringBuf();
		socket = new Socket( secure );
		socket.onConnect = sockConnectHandler;
		socket.onDisconnect = sockDisconnectHandler;
		socket.onError = sockErrorHandler;
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
	
	function sockDisconnectHandler() {
		connected = false;
		__onDisconnect(null);
	}
	
	function sockSecuredHandler() {
		secured = true;
		__onSecured( null );
	}
	
	function sockDataHandler( t : String ) {
		buf.add( t );
		var s = buf.toString();
		if( s.length > maxBufSize )
			throw new jabber.error.Error( "max socket buffer size reached ["+maxBufSize+"]" );
		if( __onString( s ) != 0 ) {
			buf = new StringBuf();
		}
	}
	
	function sockErrorHandler( e : String ) {
		connected = false;
		__onDisconnect( e );
	}
	
	///// Socketbridge connection
		
	static function __init__() {
		initialized = false;
	}
	
	public static var id(default,null) : String;
	public static var swf(default,null) : Dynamic;
	public static var initialized(default,null) : Bool;
	
	static var sockets : IntHash<Socket>;
	
	public static function init( id : String, cb : String->Void, ?delay : Int = 300 ) {
		if( initialized ) {
			#if JABBER_DEBUG
			trace( "socketbridge already initialized" );
			#end
			return;
		}
		swf = js.Lib.document.getElementById( id );
		if( swf == null ) {
			cb( "socketbridge swf not found ["+id+"]" );
			return;
		}
		SocketConnection.id = id;
		sockets = new IntHash();
		initialized = true;
		if( delay > 0 ) haxe.Timer.delay( function(){ cb(null); }, delay );
		else cb(null);
	}
	
	public static function createSocket( s : Socket, secure : Bool ) {
		var id : Int = -1;
		try id = swf.createSocket( secure ) catch( e : Dynamic ) {
			#if JABBER_DEBUG trace(e); #end
			return -1;
		}
		sockets.set( id, s );
		return id;
	}
	
	static function handleConnect( id : Int ) {
		sockets.get( id ).onConnect();
	}
	
	static function handleDisconnect( id : Int ) {
		sockets.get( id ).onDisconnect();
	}
	
	static function handleError( id : Int, e : String ) {
		sockets.get( id ).onError( e );
	}
	
	static function handleData( id : Int, d : String ) {
		sockets.get( id ).onData( d );
	}
	
	static function handleSecure( id : Int ) {
		sockets.get( id ).onSecured();
	}
}

#end
#end
