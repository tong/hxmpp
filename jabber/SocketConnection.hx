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

#if flash
import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.ByteArray;

#elseif js
	#if cra
	import chrome.Socket;
	import jabber.util.ArrayBufferUtil;
	#elseif nodejs
	import js.Node;
	private typedef Socket = js.NodeNetSocket;
	#else
	import js.html.WebSocket;
	private typedef Socket = WebSocket;
	#end

#elseif sys
import sys.net.Host;
import sys.net.Socket;

#end

/**
	Crossplatform socket connection for xmpp streams.

	Supported targets:
		#* air
		* chrome-app
		* flash
		* flashsocketbridge
		* js
		* nodejs
		* sys
*/
class SocketConnection extends jabber.StreamConnection {

	public static var defaultBufSize = #if php 65536 #else 256 #end;
	public static var defaultMaxBufSize = 1<<22; // 4MB

	public var port(default,null) : Int;
	public var timeout(default,null) : Float;
	
	#if sys
	public var bufSize : Int;
	public var maxBufSize : Int;
	#end

	var socket : Socket;

	#if (cra||sys)
	var reading : Null<Bool>;
	#end

	#if cra
	var socketId : Int;
	#end

	public function new( host : String = "localhost",
						 ?port : Null<Int>,
						 secure : Bool = false,
						 timeout : Float = 0 ) {
		
		if( port == null ) port =
			#if jabber_component
			jabber.component.Stream.PORT
			#else
			jabber.client.Stream.PORT
			#end;

		super( host, false, false );
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
		socket.addEventListener( Event.CONNECT, handleConnect );
		socket.addEventListener( Event.CLOSE, handleDisconnect );
		socket.addEventListener( IOErrorEvent.IO_ERROR, handleError );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, handleError );
		socket.connect( host, port );

		#elseif js

			#if cra
			Socket.create( 'tcp', null, function(i){
				if( i.socketId > 0 ) {
					socketId = i.socketId;
					Socket.connect( i.socketId, host, port, handleConnect );
				} else {
					onDisconnect( 'failed to create socket' );
				}
			});

			#elseif nodejs
			//TODO timeout
			socket = Node.net.connect( port, host );
			socket.setEncoding( NodeC.UTF8 );
			socket.on( NodeC.EVENT_STREAM_CONNECT, handleConnect );
			socket.on( NodeC.EVENT_STREAM_END, handleDisconnect );
			socket.on( NodeC.EVENT_STREAM_ERROR, handleError );

			#else
			//TODO timeout
			socket = new Socket( 'ws'+(secure?'s':'')+'://$host:$port' );
			socket.onopen = handleConnect;
			socket.onclose = handleDisconnect;
			socket.onerror = handleError;

			#end
			
		#elseif sys
		socket = new Socket();
		if( timeout > 0 ) socket.setTimeout( timeout );
		try socket.connect( new Host( host ), port ) catch( e : Dynamic ) {
			onDisconnect( e );
			return;
		}
		connected = true;
		onConnect();

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
		
		#if flash
		yes ? socket.addEventListener( ProgressEvent.SOCKET_DATA, handleData )
			: socket.removeEventListener( ProgressEvent.SOCKET_DATA, handleData );
		
		#elseif js
			#if cra
			if( yes ) {
				reading = true;
				_read();
			} else reading = false;
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
		} else
			reading = false;

		#end

		return true;
	}
	
	public override function disconnect() {

		connected = false;

		#if flash
		try socket.close() catch( e : Dynamic ) { onDisconnect( e ); }

		#elseif js
			#if cra
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
			#if cra
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

	#if js

		#if cra

		function handleConnect(_) {
			connected = true;
			onConnect();
		}

		function _read() {
			Socket.read( socketId, null, function(i:ReadInfo) {
				if( i.resultCode > 0 ) {
					if( reading ) {
						onData( Bytes.ofString( ArrayBufferUtil.toString( i.data ) ) ); //TODO
						_read();
					}
				}
			});
		}

		#elseif nodejs

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

		#else

		function handleConnect(_) {
			connected = true;
			onConnect();
		}

		function handleDisconnect(_) {
			handleError( null );
		}

		function handleError( e : String ) {
			connected = false;
			onDisconnect( e );
		}

		function handleData( s : String ) {
			onString( s );
		}

		#end

	#elseif flash

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

	#elseif sys

	function handleError( e : String ) {
		reading = null;
		connected = false;
		try socket.close() catch( e : Dynamic ) {
			#if jabber_debug trace( e ); #end
			return;
		}
		onDisconnect( e );
	}

	#end
	

}
