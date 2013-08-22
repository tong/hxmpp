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
package jabber.net;

#if sys

import sys.net.Host;
import haxe.io.Bytes;

#if (cpp||neko)
import sys.ssl.Socket;
#elseif php
private typedef Socket = php.net.SslSocket;
#end

#if (cpp||neko) @:require(hxssl) #end
@:require(sys)
class SecureSocketConnection_sys extends jabber.StreamConnection {

	public static var defaultBufSize = 128;
	public static var defaultMaxBufSize = 1<<20; //TODO
	public static var defaultTimeout = 10;

	public var port(default,null) : Int;
	public var socket(default,null) : Socket;
	public var reading(default,null) : Bool;
	public var maxBufSize(default,null) : Int;
	public var timeout(default,null) : Int;

	var buf : Bytes;
	var bufsize : Int;
	var bufpos : Int;

	public function new( host : String = "localhost",
						 port : Int = #if jabber_component 5275 #else 5223 #end,
						 ?bufsize : Null<Int>, ?maxBufSize : Null<Int>,
						 timeout : Null<Int> = 10 ) {
		
		super( host, true, false );
		this.port = port;
		this.bufsize = ( bufsize == null ) ? defaultBufSize : bufsize;
		this.maxBufSize = ( maxBufSize == null ) ? defaultMaxBufSize : maxBufSize;
		this.timeout = ( timeout == null ) ? defaultTimeout : timeout;

		reading = false;
		socket = new Socket();
	}

	public override function connect() {
		buf = Bytes.alloc( bufsize );
		try socket.connect( new Host( host ), port ) catch( e : Dynamic ) {
			#if jabber_debug trace(e); #end
			onDisconnect( e );
			return;
		}
		//secure =
		connected = true;
		onConnect();
	}

	public override function disconnect() {
		if( !connected )
			return;
		reading = connected = false;
		try socket.close() catch( e : Dynamic ) {
			onDisconnect( e );
		}
	}

	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		try {
			socket.write( t );
			//socket.output.flush();
		} catch(e:Dynamic) {
			#if jabber_debug trace(e); #end
			return false;
		}
		return true;
	}

	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			reading = true;
			bufpos = 0;
			while( connected ) {
				readData();
			}
		} else {
			reading = false;
		}
		return true;
	}

	function readData() {
		var len : Int;
		try {
			len = try socket.input.readBytes( buf, bufpos, bufsize );
	
		} catch( e : Dynamic ) {
			#if jabber_debug trace(e); #end
			error( "socket read failed" );
			return;
		}
		bufpos += len;
		if( len < bufsize ) {
			onData( buf.sub( 0, bufpos ) );
			bufpos = 0;
			buf = Bytes.alloc( bufsize = defaultBufSize );
		} else {
			var nsize = buf.length + bufsize;
			if( nsize > maxBufSize ) {
				error( 'max buffer size site reached ($maxBufSize)' );
				return;
			}
			var nbuf = Bytes.alloc( nsize );
			nbuf.blit( 0, buf, 0, buf.length );
			buf = nbuf;
		}
	}

	function error( info : String ) {
		reading = connected = false;
		try {
			socket.close();
		} catch( e : Dynamic ) {
			#if jabber_debug trace(e,"error"); #end
		}
		//socket = null;
		onDisconnect( info );
	}
	
}

#end
