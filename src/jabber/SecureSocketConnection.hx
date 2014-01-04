/*
 * Copyright (c), disktree.net
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
import sys.net.Host;
#if php
import php.net.SslSocket in Socket;
#else
import sys.ssl.Socket;
#end

/**
	Temporary implementation of ssl socket connection (legacy port 5223)
*/
@:require(sys)
class SecureSocketConnection extends jabber.StreamConnection {

	public static var defaultBufSize = #if php 65536 #else 256 #end;
	public static var defaultMaxBufSize = 1<<22; // 4MB

	public var port(default,null) : Int;
	public var timeout(default,null) : Float;
	
	public var bufSize : Int;
	public var maxBufSize : Int;
	public var socket : Socket;

	var reading : Null<Bool>;

	public function new( host : String = "localhost", ?port : Null<Int>,
						 secure : Bool = true,
						 timeout : Float = 0 ) {
		
		if( port == null ) port = jabber.client.Stream.PORT_SECURE;

		super( host, secure, false );
		this.port = port;
		this.timeout = timeout;
		
		bufSize = defaultBufSize;
		maxBufSize = defaultMaxBufSize;
		reading = false;
	}

	public override function connect() {
		socket = new Socket();
		if( timeout > 0 ) socket.setTimeout( timeout );
		try socket.connect( new Host( host ), port ) catch( e : Dynamic ) {
			onDisconnect( e );
			return;
		}
		connected = true;
		onConnect();
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
		return true;
	}
	
	public override function disconnect() {
		connected = false;
		try socket.close() catch( e : Dynamic ) {
			onDisconnect( e );
			return;
		}
		onDisconnect( null );
	}

	public override function write( s : String ) : Bool {
		socket.write( s );
		return true;
	}

	function handleError( e : String ) {
		reading = null;
		connected = false;
		try socket.close() catch( e : Dynamic ) {
			#if jabber_debug trace( e ); #end
			return;
		}
		onDisconnect( e );
	}

}
