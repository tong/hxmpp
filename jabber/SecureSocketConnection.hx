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

import tls.controller.SecureSocket;
import tls.event.SecureSocketEvent;
import tls.valueobject.SecurityOptionsVO;

/**
	Experimental TLS socket connection.
*/
class SecureSocketConnection extends jabber.stream.Connection {
	
	public var port(default,null) : Int;
	
	var socket : SecureSocket;
	
	public function new( host : String, port : Int = 5223 ) {
		super( host );
		this.port = port;
	}
	
	public override function connect() {
		socket = new SecureSocket();
		socket.addEventListener( SecureSocketEvent.ON_CONNECT, sockConnectHandler );
		socket.addEventListener( SecureSocketEvent.ON_SECURE_CHANNEL_ESTABLISHED, secureChannelEstablished );
		socket.addEventListener( SecureSocketEvent.ON_ERROR, sockErrorHandler );
		socket.addEventListener( SecureSocketEvent.ON_CLOSE, sockDisconnectHandler );
		socket.connect( host, port );
	}
	
	public override function write( t : String ) : Bool {
		socket.sendString( t );
		return true;
	}
	
	function sockConnectHandler( e : SecureSocketEvent ) {
		socket.startSecureSupport( SecurityOptionsVO.getDefaultOptions( SecurityOptionsVO.SECURITY_TYPE_TLS ) );
	}
	
	function sockDisconnectHandler( e : SecureSocketEvent ) {
		trace(e);
	}
	
	function secureChannelEstablished( e : SecureSocketEvent ) {
		socket.addEventListener( SecureSocketEvent.ON_PROCESSED_DATA, socketDataHandler );
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
		//socket.setTimeout( timeout );
		buf = haxe.io.Bytes.alloc( bufSize );
		bufbytes = 0;
		#if neko
		socket.connect( Socket.resolve( host ), port );
		#elseif php
		trace("CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC"+host+"//"+port);
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

#end // (neko||cpp||php||nodejs)
