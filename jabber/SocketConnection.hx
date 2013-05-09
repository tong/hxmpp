/*
 * Copyright (c) disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber;

import haxe.io.Bytes;

#if sys

import sys.net.Host;
import sys.net.Socket;

class SocketConnection extends SocketConnectionBase {
		
	public function new( host : String = "localhost",
						 port : Int = #if jabber_component 5275 #else 5222 #end,
						 secure : Bool = #if (neko||cpp||air) false #else true #end,
						 ?bufsize : Int, ?maxbufsize : Int,
						 timeout : Int = 10 ) {
		
		super( host, port, secure, bufsize, maxbufsize, timeout );
		
		#if (jabber_debug && (neko||cpp||air) )
		if( secure ) {
			trace( "start-tls not implemented, use jabber.SecureSocketConnection for legacy tls on port 5223", "warn" );
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
		#if (neko||cpp||cs||java)
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


#elseif (chrome_app)

import chrome.Socket;
import haxe.io.Bytes;
import jabber.util.ArrayBufferUtil;

class SocketConnection extends StreamConnection {
	
	public var port(default,null) : Int;
	public var socketId(default,null): Int;
	
	public function new( host : String = "localhost", port : Int = 5222 ) {
		super( host, false );
		this.port = port;
	}
	
	public override function connect() {
		Socket.create( 'tcp', null, function(i){
			if( i.socketId > 0 ) {
				socketId = i.socketId;
				Socket.connect( i.socketId, host, port, handleConnect );
			} else {
				__onDisconnect( 'unable to create socket' );
			}
		});
	}
	
	public override function disconnect() {
		Socket.disconnect( socketId );
		Socket.destroy( socketId );
		connected = false;
	}

	public override inline function read( ?yes : Bool = true ) : Bool {
		_read();
		return true;
	}
	
	public override function write( t : String ) : Bool {
		Socket.write( socketId, ArrayBufferUtil.toArrayBuffer( t ), function(info){
			//trace(info);
		});
		return true;
	}
	
	function _read() {
		Socket.read( socketId, null, function(i:ReadInfo) {
			if( i.resultCode > 0 ) {
				__onData( Bytes.ofString( ArrayBufferUtil.toString( i.data ) ) ); //TODO
				_read();
			}
		});
	}
	
	function handleConnect( status : Int ) {
		//trace( "socket status "+status, "debug" );
		if( status == 0 ) {
			connected = true;
			__onConnect();
		} else {
			//TODO (what?)
			#if jabber_debug trace("TODO"); #end
		}
	}
}


#elseif ( js && !jabber_flashsocketbridge && !nodejs && !rhino )

import js.html.WebSocket;

/**
	WebSocket connection.
	http://tools.ietf.org/html/draft-moffitt-xmpp-over-websocket-00
*/
class SocketConnection extends StreamConnection {
	
	public var url(default,null) : String;
	public var port(default,null) : Int;
	public var socket(default,null) : WebSocket;
	
	public function new( host : String = "localhost", port : Int = 5222, secure : Bool = false ) {
		
		super( host, secure );
		this.port = port;
		this.secure = secure;
		
		url = 'ws'+(secure?'s':'')+'://$host:$port'; // (unofficial) specs do not support secure websocket connections
	}
	
	public override function connect() {
		socket = new WebSocket( url );
		socket.onopen = onConnect;
		socket.onclose = onClose;
		socket.onerror = onError;
	}
	
	public override function disconnect() {
		socket.close();
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		socket.onmessage = onData;
		//if( yes ) socket.onmessage = onData;
		//socket.onmessage = yes ? onData : null;
		return true;
	}
	
	public override function write( t : String ) : Bool {
		socket.send( t );
		return true;
	}
	
	function onConnect(e) {
		connected = true;
		__onConnect();
	}
	
	function onClose(e) {
		connected = false;
		__onDisconnect(null);
	}
	
	function onError(e) {
		connected = false;
		__onDisconnect( "websocket error" ); // no error message?
	}
	
	function onData( m : Dynamic ) {
		__onString( m.data );
	}
	
	public static inline function isSupported() : Bool {
		return untyped window.WebSocket != null;
	}
}


#elseif flash

import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.ByteArray;

class SocketConnection extends SocketConnectionBase {
	
	#if air
	public var socket(default,null) : Socket;
	#end
	
	public function new( host : String = "localhost", port : Int = 5222, secure : Bool = false,
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
			#if jabber_debug trace( e, "error" ); #end
			return;
		}
		trace(d.length);
		__onData(  haxe.io.Bytes.ofData( d )  );
		*/
	}
}


#elseif (js&&droid) error // deprecated

/*
class SocketConnection extends jabber.stream.SocketConnectionBase {
	public function new( host : String = "localhost", port : Int = 5222 ) {
		super( host, port, false );
	}
}
*/


#elseif (js&&air)

import air.Socket;
import air.ByteArray;
import air.Event;
import air.IOErrorEvent;
import air.ProgressEvent;
import air.SecurityErrorEvent;

/**
	Air/Javascript
*/
class SocketConnection extends SocketConnectionBase {
	
	public function new( host : String = "localhost", port : Int = 5222, secure : Bool = false,
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
			#if jabber_debug trace( e, "error" ); #end
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
			#if jabber_debug trace( e, "error" ); #end
			return false;
		}
		return true;
	}
	
	/*
	public override function reset() {
		#if jabber_debug trace('clearing socket buffer','info'); #end
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
			#if jabber_debug trace(e,"error"); #end
			return;
		}
		__onData(  haxe.io.Bytes.ofData( d )  );
	}
}


#elseif (js&&nodejs)

import js.Node;

private typedef Socket = js.NodeNetSocket;

/**
	Node.js
*/
class SocketConnection extends SocketConnectionBase {
	
	public var socket(default,null) : Socket;
	public var credentials : NodeCredDetails;
	
	var cleartext : Dynamic;
	
	public function new( host : String = "localhost", port : Int = 5222, secure : Bool = true,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, secure, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		createConnection();
		
		socket.on( NodeC.EVENT_STREAM_END, sockDisconnectHandler );
		socket.on( NodeC.EVENT_STREAM_ERROR, sockErrorHandler );
		socket.on( NodeC.EVENT_STREAM_DATA, sockDataHandler );
	}
	
	public override function disconnect() {
		if( !connected )
			return;
		try socket.end() catch( e : Dynamic ) {
			__onDisconnect( e );
		}
	}
	
	public override function setSecure() {
		//TODO 'setSecure' got removed from nodejs 0.4+
		trace("_____SET SECURE__________TODO");
		
		/*
		socket.removeAllListeners( 'data' );
		socket.removeAllListeners( 'drain' );
		socket.removeAllListeners( 'close' );
		socket.on( 'secureConnect', function(){ trace("SSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSSS"); } );
		
		if( credentials == null ) credentials = cast {};
		trace(".......");
		var ctx = jabber.util.StartTLS.run( socket, credentials, true, function() {
			trace(">>>>>>>>>>>>>");
		});
		*/
		
		//secured = true;
		//__onSecured( null );
		// hmm? TypeError: Object #<a Stream> has no method 'setSecure' ??????????
		//socket.on( Node.STREAM_SECURE, sockSecureHandler );
		//trace( socket.getPeerCertificate() );
//		socket.setSecure(  );
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
			socket.removeListener( NodeC.EVENT_STREAM_DATA, sockDataHandler );
		return true;
	}
	
	function createConnection() {
		//if( credentials == null ) credentials = cast {};
		//socket = Node.tls.connect( port, host, credentials, sockConnectHandler );
		//socket = Node.net.connect( port, host, sockConnectHandler );
		socket = Node.net.connect( port, host );
		socket.setEncoding( NodeC.UTF8 );
		socket.on( NodeC.EVENT_STREAM_CONNECT, sockConnectHandler );
		/*
		socket = Node.net.createConnection( port, host );
		socket.setEncoding( Node.UTF8 );
		//socket = Node.tls.connect( port, host, null, sockConnectHandler );
		socket.on( Node.STREAM_CONNECT, sockConnectHandler );
		*/
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


#elseif (js&&jabber_flashsocketbridge)

import jabber.SocketConnectionBase;

/**
	JS + FlashSocketBridge
*/
class SocketConnection extends SocketConnectionBase {

	public function new( host : String = "localhost", ?port : Int = 5222, secure = true, timeout : Int = 10 ) {
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
	
	static function __init__() {
		initialized = false;
	}
	
	/** The id of the html element holding the swf */
	public static var id(default,null) : String;
	
	/** Reference to the swf itself */
	public static var swf(default,null) : Dynamic;
	
	/** Indicates if the socketbridge stuff is initialized */
	public static var initialized(default,null) : Bool;
	
	static var sockets : Map<Int,Socket>;
	
	public static function init( id : String = "localhost", cb : String->Void, ?delay : Int = 0 ) {
		if( initialized ) {
			#if jabber_debug trace( 'socketbridge already initialized ['+id+']', 'warn' ); #end
			cb( 'socketbridge already initialized ['+id+']' );
			return;
		}
		var _init : Void->Void = function(){
			swf = untyped document.getElementById( id );
			if( swf == null ) {
				#if jabber_debug trace( 'socketbridge swf not found ['+id+']', 'warn' ); #end
				cb( 'socketbridge swf not found ['+id+']' );
				return;
			}
			sockets = new Map();
			initialized = true;
			cb(null);
		}
		if( delay > 0 ) haxe.Timer.delay( _init, delay ) else _init();
	}
	
	public static function createSocket( s : Socket, secure : Bool, timeout : Int ) {
		var id : Int = -1;
		try id = swf.createSocket( secure, false, timeout ) catch( e : Dynamic ) {
			#if jabber_debug trace( e, "error" ); #end
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

#end // js && jabber_flashsocketbridge
