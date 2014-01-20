/*
 * Copyright (c) disktree
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

#if !jabber_flashsocketbridge

#if flash
import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.ByteArray;
#elseif js
	#if chrome_app
	import chrome.Socket;
	import jabber.util.ArrayBufferUtil;
	#elseif nodejs
	import js.Node;
	import js.Node.NodeNetSocket in Socket;
	#else
	import js.html.WebSocket in Socket;
	#end
#elseif sys
import sys.net.Host;
import sys.net.Socket;
#end

/**
	Crossplatform socket connection.
*/
class SocketConnection extends jabber.StreamConnection {

	public static var defaultBufSize = #if php 65536 #else 256 #end;
	public static var defaultMaxBufSize = 1<<22; // 4MB

	public var port(default,null) : Int;
	public var timeout(default,null) : Float;
	public var socket : Socket;
	
	#if sys
	public var bufSize : Int;
	public var maxBufSize : Int;
	#end

	#if (chrome_app||sys)
	var reading : Null<Bool>;
	#end

	#if chrome_app
	var socketId : Int;
	#end

	public function new( host : String = "localhost", ?port : Null<Int>,
						 secure : Bool = false, timeout : Float = 0 ) {
		
		if( port == null ) port = #if jabber_component jabber.component.Stream.PORT #else jabber.client.Stream.PORT #end;

		super( host, secure, false );
		this.port = port;
		this.timeout = timeout;
		
		#if sys
		bufSize = defaultBufSize;
		maxBufSize = defaultMaxBufSize;
		reading = false;
		#end
	}

	public override function connect() {
		#if flash
		socket = new Socket();
		if( timeout > 0 ) socket.timeout = Std.int( timeout*1000 );
		socket.addEventListener( Event.CONNECT, handleConnect, false );
		socket.addEventListener( Event.CLOSE, handleDisconnect, false );
		socket.addEventListener( IOErrorEvent.IO_ERROR, handleError, false );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, handleError, false );
		socket.connect( host, port );
		#elseif (js&&chrome_app)
		Socket.create( 'tcp', {}, function(info){
			if( info.socketId > 0 ) {
				Socket.connect( socketId = info.socketId, host, port, handleConnect );
			} else {
				onDisconnect( 'failed to create socket' );
			}
		});
		#elseif (js&&nodejs)
		//TODO timeout
		socket = Node.net.connect( port, host );
		socket.setEncoding( NodeC.UTF8 );
		socket.on( NodeC.EVENT_STREAM_CONNECT, handleConnect );
		socket.on( NodeC.EVENT_STREAM_END, handleDisconnect );
		socket.on( NodeC.EVENT_STREAM_ERROR, handleError );
		#elseif js
		var uri = 'ws'+(secure?'s':'')+'://$host:$port';
		socket = new Socket( uri );
		socket.onopen = handleConnect;
		socket.onclose = handleDisconnect;
		socket.onerror = handleError;
		#elseif sys
		trace("AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAa");
		socket = new Socket();
		if( timeout > 0 ) socket.setTimeout( timeout );
		try socket.connect( new Host( host ), port ) catch( e : Dynamic ) {
			#if jabber_debug trace(e); #end
			onDisconnect( e );
			return;
		}
		connected = true;
		if( onConnect != null ) onConnect();
		#end
	}

	public override function setSecure() {
		#if php
		try secured = untyped __call__( 'stream_socket_enable_crypto', socket.__s, true, 1 ) catch( e : Dynamic ) {
			onSecured( e );
			return;
		}
		onSecured( null );
		#else
		throw "Start-TLS not implemented";
		#end
	}

	public override function read( ?yes : Bool = true ) : Bool {
		trace("read");
		#if flash
		yes ? socket.addEventListener( ProgressEvent.SOCKET_DATA, handleData )
			: socket.removeEventListener( ProgressEvent.SOCKET_DATA, handleData );
		#elseif js
			#if chrome_app
			if( yes ) {
				reading = true;
				_read();
			} else
				reading = false;
			#elseif nodejs
			yes ? socket.on( NodeC.EVENT_STREAM_DATA, handleData )
				: socket.removeListener( NodeC.EVENT_STREAM_DATA, handleData );
			#else
			socket.onmessage = yes ? handleData : null;
			#end
		#elseif sys
		if( yes ) {
			reading = true;
			var buf = Bytes.alloc( bufSize );
			var pos = 0;
			var len : Int;
			while( connected && reading ) {
				try len = try socket.input.readBytes( buf, pos, bufSize ) catch( e : Dynamic ) {
					handleError( e );
					return false;
				}
				pos += len;
				if( len < bufSize ) {
					onData( buf.sub( 0, pos ) );
					pos = 0;
					buf = Bytes.alloc( bufSize = defaultBufSize );
				} else {
					var nsize = buf.length + bufSize;
					if( nsize > maxBufSize ) {
						handleError( 'max read buffer size reached ($maxBufSize)' );
						return false;
					}
					var nbuf = Bytes.alloc( nsize );
					nbuf.blit( 0, buf, 0, buf.length );
					buf = nbuf;
				}
			}
		} else reading = false;
		#end
		return true;
	}
	
	public override function disconnect() {
		connected = false;
		#if flash
		try socket.close() catch( e : Dynamic ) { onDisconnect( e ); }
		#elseif js
			#if chrome_app
			Socket.disconnect( socketId );
			Socket.destroy( socketId );
			#elseif nodejs
			try socket.end() catch( e : Dynamic ) { onDisconnect( e ); }
			#else
			try socket.close() catch( e : Dynamic ) { onDisconnect( e ); }
			#end
		#elseif sys
		try socket.close() catch( e : Dynamic ) {
			onDisconnect( e );
			return;
		}
		onDisconnect( null );
		#end
	}

	public override function write( s : String ) : Bool {
		#if flash
		socket.writeUTFBytes( s ); 
		socket.flush();
		#elseif js
			#if chrome_app
			Socket.write( socketId, ArrayBufferUtil.toArrayBuffer(s), function(e){} );
			#elseif nodejs
			socket.write( s );
			#else
			socket.send( s );
			#end
		#elseif sys
		socket.write( s );
		#end
		return true;
	}
	
	#if flash

	function handleConnect( e : Event ) {
		connected = true;
		onConnect();
	}

	function handleDisconnect( e : Event ) {
		connected = false;
		onDisconnect( null );
	}

	function handleError( e : Event ) {
		connected = false;
		onDisconnect( e.type );
	}

	function handleData( e : ProgressEvent ) {
		var data = new ByteArray();
		socket.readBytes( data, 0, Std.int( e.bytesLoaded ) );
		onData( Bytes.ofData( data )  );
	}

	#elseif (js&&chrome_app)

	function handleConnect(_) {
		connected = true;
		onConnect();
	}

	function _read() {
		Socket.read( socketId, null, function(i:SocketReadInfo) {
			if( i.resultCode > 0 ) {
				if( reading ) {
					onData( Bytes.ofString( ArrayBufferUtil.toString( i.data ) ) ); //TODO
					_read();
				}
			}
		});
	}

	#elseif (js&&nodejs)

	function handleConnect() {
		connected = true;
		onConnect();
	}

	function handleDisconnect() {
		handleError( null );
	}

	function handleError( e : String ) {
		connected = false;
		onDisconnect( e );
	}

	function handleData( s : String ) {
		onString( s );
	}

	#elseif js

	function handleConnect(_) {
		trace("handleConnect");
		connected = true;
		onConnect();
	}

	function handleDisconnect(_) {
		trace("handleDisconnect");
		handleError( null );
	}

	//function handleError( e : String ) {
	function handleError( e ) {
		trace("handleError "+e);
		trace(e);
		connected = false;
		onDisconnect( e );
	}

	function handleData( s : String ) {
		trace("handleData");
		onString( s );
	}

	#elseif sys

	function handleError( e : String ) {
		reading = null;
		connected = false;
		try socket.close() catch( e : Dynamic ) {
			#if jabber_debug trace(e); #end
			return;
		}
		onDisconnect( e );
	}

	#end
}

#else // jabber_flashsocketbridge

@:keep
@:expose
@:require(js)
class SocketConnection extends jabber.StreamConnection {

	/** The id of the html element holding the swf */
	public static var id(default,null) : String;
	
	/** Reference to the swf itself */
	public static var swf(default,null) : Dynamic;
	
	/** Indicates if the socketbridge stuff is initialized */
	public static var initialized(default,null) : Bool = false;
	
	static var sockets : Map<Int,Socket>;
	
	public static function init( id : String, cb : String->Void, ?delay : Int = 0 ) {
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

	public var socket(default,null) : Socket;
	public var port(default,null) : Int;
	public var timeout(default,null) : Int;

	public function new( host : String = "localhost", ?port : Int = 5222, secure = false, timeout : Int = 10 ) {
		super( host, secure, false );
		this.port = port;
		this.timeout = timeout;
	}

	public override function connect() {
		if( !SocketConnection.initialized )
			throw "flashsocketbridge not initialized";
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
			onDisconnect( e );
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
		onConnect();
	}
	
	function sockDisconnectHandler( ?e : String ) {
		connected = false;
		onDisconnect( e );
	}
	
	function sockSecuredHandler() {
		secured = true;
		onSecured( null );
	}
	
	function sockDataHandler( t : String ) {
		onString( t );
	}
}

@:keep
@:require(js)
private class Socket {
	
	public dynamic function onConnect() {}
	public dynamic function onDisconnect( ?e : String ) {}
	public dynamic function onData( d : String ) {}
	public dynamic function onSecured() {}
	
	public var id(default,null) : Int;
	
	@:allow(jabber.SocketConnection)
	function new( secure : Bool, timeout : Int = 10 ) {
		id = jabber.SocketConnection.createSocket( this, secure, timeout );
		if( id < 0 )
			throw "failed to create socket on flash bridge";
	}
	
	public inline function connect( host : String, port : Int, ?timeout : Int ) {
		jabber.SocketConnection.swf.connect( id, host, port, timeout );
	}
	
	public inline function close() {
		jabber.SocketConnection.swf.disconnect( id );
	}
	
	public inline function send( t : String ) {
		jabber.SocketConnection.swf.send( id, t );
	}
	
	public inline function setSecure() {
		jabber.SocketConnection.swf.setSecure( id );
	}
}

#end // jabber_flashsocketbridge
