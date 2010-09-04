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

// Legacy socket connection on port 5223

#if (neko||php||cpp)

#if neko
import neko.tls.Socket;
#elseif php
import php.net.Host;
import jabber.util.php.Socket;
#elseif cpp
import cpp.net.Host;
import cpp.net.Socket;
#end

// TODO extend jabber.SocketConnection
class SecureSocketConnection extends jabber.stream.SocketConnection<Socket> {
	
	public function new( host : String, port : Int = 5223, secure : Bool = true,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, secure, bufSize, maxBufSize, timeout );
		reading = false;
	}
	
	public override function connect() {
		socket = new Socket();
		buf = haxe.io.Bytes.alloc( bufSize );
		bufbytes = 0;
		#if neko
		socket.connect( Socket.resolve( host ), port );
		#elseif php
		socket.connectTLS( new php.net.Host( host ), port );
		#end
		secured = true;
		connected = true;
		__onConnect();
	}
	
	public override function disconnect() {
		if( !connected )
			return;
		reading = connected = false;
		try socket.close() catch( e : Dynamic ) {
			trace(e);
			__onError( "Error closing socket" );
			return;
		}
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		reading = true;
		while( reading )
			readData();
		return true;
	}
	
	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.write( t );
		socket.output.flush();
		return true;
	}
	
	/*
	public override function setSecure() {
		trace( "DO NOTHING");
	}
	*/
	
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
}

#elseif flash

#if air
import flash.net.SecureSocket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.ByteArray;

class SecureSocketConnection extends jabber.stream.SocketConnection<SecureSocket> {
	
	var buf : ByteArray;
	
	public function new( host : String, port : Int = 5223,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, true, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		buf = new ByteArray();
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
			trace(e);
			__onError( "Error closing socket" );
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
		__onDisconnect();
	}
	
	function sockErrorHandler( e : Event ) {
		connected = false;
		__onError( e.type );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		try socket.readBytes( buf, buf.length, e.bytesLoaded ) catch( e : Dynamic ) {
			#if JABBER_DEBUG
		//	trace(e);
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
}

#elseif TLS

import tls.event.SecureSocketEvent;
import tls.valueobject.SecurityOptionsVO;

class SecureSocketConnection extends jabber.SocketConnection {
	
	public function new( host : String, port : Int = 5223,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, true, bufSize, maxBufSize, timeout );
	}
	
	override function sockConnectHandler( e : SecureSocketEvent ) {
		socket.startSecureSupport( SecurityOptionsVO.getDefaultOptions( SecurityOptionsVO.SECURITY_TYPE_TLS ) );
	}
	
	override function secureChannelEstablished( e : SecureSocketEvent ) {
		connected = true;
		__onConnect();
	}
}
#end //TLS

#elseif js

#if air
import air.ByteArray;
import air.SecureSocket;
import air.Event;
import air.IOErrorEvent;
import air.SecurityErrorEvent;
import air.ProgressEvent;

class SecureSocketConnection extends jabber.stream.SocketConnection<SecureSocket> {
	
	var buf : ByteArray;
	
	public function new( host : String, port : Int = 5223,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, true, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		buf = new ByteArray();
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
			trace(e);
			__onError( "Error closing socket" );
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
		__onDisconnect();
	}
	
	function sockErrorHandler( e : Event ) {
		connected = false;
		__onError( e.type );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		try socket.readBytes( buf, buf.length, e.bytesLoaded ) catch( e : Dynamic ) {
			#if JABBER_DEBUG
		//	trace(e);
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
}


#elseif nodejs
class SecureSocketConnection extends jabber.SocketConnection {
	public function new( host : String, port : Int = 5222,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, true, bufSize, maxBufSize, timeout );
	}
	override function sockConnectHandler() {
		socket.setSecure();
		super.sockConnectHandler();
	}
}
#end //js

#end
