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

#if flash
import flash.utils.ByteArray;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
#if air
import flash.net.SecureSocket;
#else
import tls.controller.SecureSocket;
import tls.event.SecureSocketEvent;
import tls.valueobject.SecurityOptionsVO;
#end

/**
	Experimental TLS socket connection.
*/
class SecureSocketConnection extends jabber.stream.Connection {
	
	#if air
	public static var defaultBufSize = 128;
	public static var defaultMaxBufSize = 131072;
	#end
	
	public var port(default,null) : Int;
	#if air
	public var maxBufSize(default,null) : Int;
	public var bufSize(default,null) : Int;
	#end
	
	var socket : SecureSocket;
	#if air
	var buf : ByteArray;
	#end
	
	public function new( host : String, port : Int = 5223
						 #if air,
						 ?bufSize : Int,
						 ?maxBufSize : Int
						 #end ) {
		super( host );
		this.port = port;
		#if air
		this.bufSize = ( bufSize == null ) ? defaultBufSize : bufSize;
		this.maxBufSize = ( maxBufSize == null ) ? defaultMaxBufSize : maxBufSize;
		#end
	}
	
	public override function connect() {
		socket = new SecureSocket();
		#if air
		buf = new ByteArray();
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
		#else
		socket.addEventListener( SecureSocketEvent.ON_CONNECT, sockConnectHandler );
		socket.addEventListener( SecureSocketEvent.ON_SECURE_CHANNEL_ESTABLISHED, secureChannelEstablished );
		socket.addEventListener( SecureSocketEvent.ON_CLOSE, sockDisconnectHandler );
		socket.addEventListener( SecureSocketEvent.ON_ERROR, sockErrorHandler );
		#end
		socket.connect( host, port );
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			#if air
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			#else
			socket.addEventListener( SecureSocketEvent.ON_PROCESSED_DATA, socketDataHandler );
			#end
		} else {
			#if air
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			#else
			socket.removeEventListener( SecureSocketEvent.ON_PROCESSED_DATA, socketDataHandler );
			#end
		}
		return true;
	}
	
	public override function write( t : String ) : Bool {
		#if air
		socket.writeUTFBytes( t ); 
		socket.flush();
		#else
		socket.sendString( t );
		#end
		return true;
	}
	
	#if air
	
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
		socket.readBytes( buf, buf.length, e.bytesLoaded );
		var b = haxe.io.Bytes.ofData( untyped buf );
		if( b.length > maxBufSize )
			throw "Max buffer size reached ("+maxBufSize+")";
		if( __onData(  b, 0, b.length ) > 0 )
			buf = new ByteArray();
		//socket.flush();
	}
	
	#else

	function sockConnectHandler( e : SecureSocketEvent ) {
		socket.startSecureSupport( SecurityOptionsVO.getDefaultOptions( SecurityOptionsVO.SECURITY_TYPE_TLS ) );
	}
	
	function sockDisconnectHandler( e : SecureSocketEvent ) {
		connected = false;
		__onDisconnect();
	}
	
	function secureChannelEstablished( e : SecureSocketEvent ) {
		//socket.addEventListener( SecureSocketEvent.ON_PROCESSED_DATA, socketDataHandler );
		connected = true;
		__onConnect();
	}
	
	function sockErrorHandler( e : SecureSocketEvent ) {
		trace(e);
	}
	
	function socketDataHandler( e : SecureSocketEvent ) {
		if( e.rawData != null ) {
			var b = haxe.io.Bytes.ofData( e.rawData );
			__onData( b, 0, b.length  );
		}
	}
	
	#end // !air
	
}


#elseif (neko||cpp||php)


#if neko
import neko.ssl.Socket;
#elseif php
import php.net.Host;
import jabber.util.php.Socket;
#end

/**
	Experimental SSL socket connection for neko (php).
	Source files and NDLL from the 'hxssl' project are required.
	See: http://disktree.spektral.at/git/?a=summary&p=hxssl
*/
class SecureSocketConnection extends jabber.stream.Connection {
	
	public static var defaultBufSize = #if php 65536 #else 128 #end; //TODO php buf
	public static var defaultMaxBufSize = 131072;
	
	public var port(default,null) : Int;
	public var bufSize(default,null) : Int;
	public var maxBufSize(default,null) : Int;
	public var timeout(default,null) : Int;
	
	var socket : Socket;
	var reading : Bool;
	var buf : haxe.io.Bytes;
	var bufbytes : Int;

	public function new( host : String, port : Int = 5223,
						 ?bufSize : Int,
						 ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host );
		this.host = host;
		this.port = port;
		this.bufSize = ( bufSize == null ) ? defaultBufSize : bufSize;
		this.maxBufSize = ( maxBufSize == null ) ? defaultMaxBufSize : maxBufSize;
		this.timeout = timeout;	
		reading = false;
	}
	
	public override function connect() {
		socket = new Socket();
		//TODO socket.setTimeout( timeout );
		buf = haxe.io.Bytes.alloc( bufSize );
		bufbytes = 0;
		#if neko
		socket.connect( Socket.resolve( host ), port );
		#elseif php
		socket.connectTLS( new php.net.Host( host ), port );
		#end
		connected = true;
		__onConnect();
	}
	
	public override function disconnect() {
		if( !connected )
			return;
		socket.close();
		#if (neko||php||cpp)
		reading = false;
		#end
		connected = false;
	}

	public override function read( ?yes : Bool = true ) : Bool {
		reading = true;
		while( reading ) {
			readData();
		}
		return true;
	}
	
	public override function write( t : String ) : Bool {
		socket.write( t );
		socket.output.flush();
		return true;
	}
	
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
			buf = haxe.io.Bytes.alloc( defaultBufSize );
	}
	
}


//#end // (neko||cpp||php||nodejs)
#elseif nodejs


import js.Node;

private typedef Socket = Stream;

class SecureSocketConnection extends jabber.stream.Connection {
	
	public static var defaultBufSize = 128;
	public static var defaultMaxBufSize = 131072;
	
	public var port(default,null) : Int;
	public var maxBufSize(default,null) : Int;
	
	var socket : Socket;
	var buf : String;
	
	public function new( host : String, port : Int = 5223,
						 ?maxBufSize : Int ) {
		super( host );
		this.maxBufSize = ( maxBufSize == null ) ? defaultMaxBufSize : maxBufSize;
	}
	
	public override function connect() {
		buf = "";
		socket = Node.net.createConnection( port, host );
		// TODO hmmm socket.setSecure();
		socket.addListener( "connect", sockConnectHandler );
		socket.addListener( "end", sockDisconnectHandler );
		socket.addListener( "error", sockErrorHandler );
		socket.addListener( "drain", sockDrainHandler );
		socket.addListener( "data", sockDataHandler );
		
	}
	
	public override function disconnect() {
		socket.end();
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			//.............
		} else {
			//TODO check
			socket.removeListener( "data", sockDataHandler );
		}
		return true;
	}
	
	public override function write( t : String ) : Bool {
		socket.write( t );
		return true;
	}

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
	
	function sockDrainHandler() {
		//TODO
		trace("NODEJS:socket drain");
	}
	
}

#end
