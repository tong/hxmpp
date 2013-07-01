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
package jabber.net;

import sys.net.Host;
import sys.net.Socket;
import haxe.io.Bytes;

private typedef AbstractSocket = {
	var input(default,null) : haxe.io.Input;
	var output(default,null) : haxe.io.Output;
	function connect( host : Host, port : Int ) : Void;
	function setTimeout( t : Float ) : Void;
	function write( str : String ) : Void;
	function close() : Void;
	function shutdown( read : Bool, write : Bool ) : Void;
	//function setBlocking( b : Bool ) : Void;
	//function setCertificateLocations( ?certFile : String, ?certFolder : String ) : Void;
}

class SocketConnectionBase_sys extends jabber.StreamConnection {
	
	public static var defaultBufSize = #if php 65536 #else 256 #end; //TODO php buf
	public static var defaultMaxBufSize = 1<<22; // 4MB
	public static var defaultTimeout = 10;
	
	public var port(default,null) : Int;
	public var maxbufsize(default,null) : Int;
	public var timeout(default,null) : Int;
	public var socket(default,null) : AbstractSocket;
	public var reading(default,null) : Bool;

	var buf : Bytes;
	var bufpos : Int;
	var bufsize : Int;

	function new( host : String, port : Int, secure : Bool,
				  bufsize : Int = -1, maxbufsize : Int = -1,
				  timeout : Int = -1 ) {
		super( host, secure, false );
		this.port = port;
		this.bufsize = ( bufsize == -1 ) ? defaultBufSize : bufsize;
		this.maxbufsize = ( maxbufsize == -1 ) ? defaultMaxBufSize : maxbufsize;
		this.timeout = ( timeout == -1 ) ? defaultTimeout : timeout;
		#if (neko||cpp||php||rhino)
		this.reading = false;
		#end
	}

	public override function disconnect() {
		if( !connected )
			return;
		reading = connected = false;
		try socket.close() catch( e : Dynamic ) {
			onDisconnect( e );
			return;
		}
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			reading = true;
			while( reading  && connected ) {
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
			if( nsize > maxbufsize ) {
				error( 'max buffer size site reached ($maxbufsize)' );
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
		onDisconnect( info );
	}
	
}
