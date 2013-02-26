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

#if (sys||rhino)

#if neko
import neko.tls.Socket;
#elseif php
import php.net.SslSocket;
#end

class SecureSocketConnection extends jabber.SocketConnectionBase {
		
	public function new( host : String, port : Int = 5223, secure : Bool = true,
						 ?bufsize : Int, ?maxbufsize : Int,
						 timeout : Int = 10 ) {
		super( host, port, secure, bufsize, maxbufsize, timeout );
	}
	
	public override function connect() {
		socket = #if php new SslSocket(); #else new Socket(); #end
		buf = haxe.io.Bytes.alloc( bufsize );
		bufpos = 0;
		try socket.connect( new sys.net.Host( host ), port ) catch( e : Dynamic ) {
			__onDisconnect( e );
			return;
		}
		secured = true;
		connected = true;
		__onConnect();
	}
	
	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.write( t );
		socket.output.flush();
		return true;
	}
}

#elseif flash

#if air
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.net.SecureSocket;
import flash.utils.ByteArray;

class SecureSocketConnection extends jabber.SocketConnectionBase {
	
	public var socket(default,null) : SecureSocket;
	
	public function new( host : String, port : Int = 5223,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, true, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		socket = new SecureSocket();
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
		__onDisconnect(null);
	}
	
	function sockErrorHandler( e : Event ) {
		connected = false;
		__onDisconnect( e.type );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		var d = new ByteArray();
		socket.readBytes( d, 0, Std.int(e.bytesLoaded) );
		__onData( haxe.io.Bytes.ofData( d ) );
	}
}


#end

#elseif js

#if droid

class SecureSocketConnection extends jabber.stream.SocketConnection {
	public function new( host : String, port : Int = 5223 ) {
		super( host, port, true );
	}
}

#elseif air
import haxe.io.Bytes;
import air.ByteArray;
import air.SecureSocket;
import air.Event;
import air.IOErrorEvent;
import air.SecurityErrorEvent;
import air.ProgressEvent;

class SecureSocketConnection extends jabber.SocketConnectionBase {
	
	public function new( host : String, port : Int = 5223,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, true, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		buf = Bytes.alloc( bufsize );
		socket = new SecureSocket();
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
			__onDisconnect( "Error closing socket" );
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
		__onDisconnect(null);
	}
	
	function sockErrorHandler( e : Event ) {
		connected = false;
		__onDisconnect( e.type );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		var d = new ByteArray();
		socket.readBytes( d, 0, Std.int(e.bytesLoaded) );
		__onData(  haxe.io.Bytes.ofData( d )  );
	}
}

/*
#elseif jabber_flashsocketbridge

class SecureSocketConnection extends jabber.SocketConnection {
	public function new( host : String, ?port : Int = 5223, secure = true, ?bufSize : Int, ?maxBufSize : Int, timeout : Int = 10) {
		super( host, port, true );
	}
}
*/

#elseif nodejs

import js.Node;
import haxe.io.Bytes;

class SecureSocketConnection extends jabber.SocketConnection {
	
	public function new( host : String, port : Int = 5223,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, true, bufSize, maxBufSize, timeout );
	}
	
	override function createConnection() {
		if( credentials == null ) {
			#if jabber_debug
			trace( "no tls credenntials set!", "warn" );
			#end
			credentials = cast {};
		}
		socket = Node.tls.connect( port, host, credentials, sockConnectHandler );
		socket.setEncoding( Node.UTF8 );
	}
}

#end //js
#end
