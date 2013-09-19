/*
 * Copyright (c) 2012, disktree.net
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
package jabber.data.io;

#if (neko||cpp)
import sys.net.Host;
import sys.net.Socket;
#end
import haxe.io.Bytes;
import jabber.util.SOCKS5Input;
#if neko
import neko.vm.Thread;
#elseif cpp
import cpp.vm.Thread;
#elseif nodejs
import js.Node;
typedef Socket = Stream;
#elseif (air&&flash)
import flash.events.ServerSocketConnectEvent;
import flash.net.Socket;
import flash.net.ServerSocket;
import flash.utils.ByteArray;
#elseif (air&&js)
import air.ServerSocketConnectEvent;
import air.Socket;
import air.ServerSocket;
import air.ByteArray;
#end

/**
	SOCKS5 bytestream output.
*/
class ByteStreamOutput extends ByteStreamIO  {
	
	public var __onConnect : ByteStreamOutput->Void;
	public var __onProgress : Int->Void;
	
	//var range : xmpp.file.Range;
	var socket : Socket;
	var digest : String;
	
	#if (neko||cpp||php)
	var server : Socket;
	
	#elseif nodejs
	var server : Server;
	
	#elseif air
	var server : ServerSocket;
	
	#end
	
	public function new( host : String, port : Int ) {
		super( host, port );
	}
	
	public function init( digest : String ) {
		
		#if jabber_debug
		trace( "Starting file transfer server ["+host+":"+port+"]" );
		#end
		
		this.digest = digest;
		
		#if (neko||cpp)
		server = new Socket();
		try {
			server.bind( new Host( host ), port );
		} catch( e : Dynamic ) {
			__onFail( e );
			return;
		}
        server.listen( 1 );
		var t = Thread.create( t_wait );
		t.sendMessage( Thread.current() );
		t.sendMessage( server );
		t.sendMessage( host );
		t.sendMessage( port );
		t.sendMessage( callbackConnect );
		
		#elseif nodejs
		server = Node.net.createServer( onConnect );
		server.listen( port, host );
		
		#elseif air
		server = new ServerSocket();
		server.bind( port, host );
		server.addEventListener( ServerSocketConnectEvent.CONNECT, onConnect );
		server.listen( 1 );
		
		#end
	}
	
	public function send( input : haxe.io.Input, size : Int, bufsize : Int ) {

		#if jabber_debug
		trace( "Transfering file [size:"+size+",bufsize:"+bufsize+"]" );
		#end
		
		#if (neko||cpp)
		socket = Thread.readMessage( false );
		if( socket == null ) {
			cleanup();
			__onFail( "Client socket not connected" );
			return;
		}
		var t = Thread.create( t_send );
		t.sendMessage( socket );
		t.sendMessage( input );
		t.sendMessage( size );
		t.sendMessage( bufsize );
		t.sendMessage( __onProgress );
		t.sendMessage( callbackSent );
		
		#elseif nodejs
		var pos = 0;
		while( pos != size ) {
			var remain = size-pos;
			var len = ( remain > bufsize ) ? bufsize : remain;
			var buf = Bytes.alloc( len );
			try {
				pos += input.readBytes( buf, 0, len );
				socket.write( buf.getData() );
				__onProgress( pos );
			} catch( e : Dynamic ) {
				cleanup();
				__onFail( e );
				return;
			}
		}
		cleanup();
		__onComplete();
		
		#elseif air
		var pos = 0;
		while( pos != size ) {
			var remain = size-pos;
			var len = ( remain > bufsize ) ? bufsize : remain;
			var buf = Bytes.alloc( len );
			try {
				pos += input.readBytes( buf, 0, len );
				socket.writeBytes( buf.getData() );
				socket.flush();
			} catch( e : Dynamic ) {
				cleanup();
				__onFail( e );
				return;
			}
		}
		cleanup();
		__onComplete();
		
		#end
	}
	
	//force close unused bytestream transport
	public function close() {
		cleanup();
	}
	
	
	#if (neko||cpp)
	
	function callbackConnect( err : String ) {
		if( err == null ) __onConnect( this );
		else {
			cleanup();
			__onFail( err );
		}
	}
	
	function callbackSent( err : String ) {
		cleanup();
		( err == null ) ? __onComplete() : __onFail( err );
	}
	
	function t_wait() {
		var main : Thread = Thread.readMessage ( true );
		var server : Socket = Thread.readMessage( true );
		var ip : String = Thread.readMessage( true );
		var port : Int = Thread.readMessage( true );
		var cb : String->Void = Thread.readMessage( true );
		var c : Socket = null;
		c = server.accept();
		main.sendMessage( c );
		// /TODO websocket handshake
		/*
		try {
			var i = c.input.readByte(); // must be 0x05 for SOCKS5
			trace( i );
			if( i == 71 ) {
				if( jabber.util.WebSocketHandshake.run( c ) ) {
					trace("OKOK websocket handshaked");
				}
			}
		} catch( e : Dynamic ) {
			trace( e );
		}
		*/
		/* //TODO flashpolicy
		try {
			var r = c.input.read( 23 ).toString();
			jabber.util.FlashPolicy.allow( r, c, ip, port );
		} catch( e : Dynamic ) {
			trace(e);
		}
		*/
		try new SOCKS5Input().run( c, digest ) catch( e : Dynamic ) {
			cb( e );
			return;
		}
		cb( null );
	}
	
	function t_send() {
		var socket : Socket = Thread.readMessage( true );
		var input : haxe.io.Input = Thread.readMessage( true );
		var size : Int = Thread.readMessage( true );
		var bufsize : Int = Thread.readMessage( true );
		var onProgress : Int->Void = Thread.readMessage( true );
		var cb : String->Void = Thread.readMessage( true );
		var pos = 0;
		while( pos < size ) {
			var remain = size-pos;
			var len = ( remain > bufsize ) ? bufsize : remain;
			var buf = Bytes.alloc( len );
			try {
				pos += input.readBytes( buf, 0, len );
				socket.output.write( buf );
				socket.output.flush();
			} catch( e : Dynamic ) {
				cb( e );
				return;
			}
			onProgress( pos );
		}
		cb( null );
	}
	
	function cleanup() {
		if( socket != null ) try socket.close() catch( e : Dynamic ) { #if jabber_debug trace(e); #end }
		if( server != null ) try server.close() catch( e : Dynamic ) { #if jabber_debug trace(e); #end }
	}
	
	
	#elseif nodejs
	
	function onConnect( s : Stream ) {
		socket = s;
		//socket.on( Node.EVENT_STREAM_DATA, onData );
		new SOCKS5Input().run( socket, digest, onSOCKS5Complete );
	}
	
	/*
	function onData( buf : Buffer ) {
		switch( buf[0] ) {
		case 71 :
			jabber.util.WebSocketHandshake.run( socket, buf );
		case 5 :
			new SOCKS5In().run( socket, digest, onSOCKS5Complete );
		}
	}
	*/
	
	function onSOCKS5Complete( err : String ) {
		if( err != null ) {
			cleanup();
			__onFail( "SOCKS5 failed: "+err );
		} else {
			__onConnect( this );
		}
	}
	
	function cleanup() {
		if( socket != null ) socket.end();
		if( server != null ) server.close();
	}
	
	
	#elseif air
	
	function onConnect( e : ServerSocketConnectEvent ) {
		socket = e.socket;
		new SOCKS5Input().run( socket, digest, onSOCKS5Complete );
	}
	
	function onSOCKS5Complete( err : String ) {
		if( err != null ) {
			cleanup();
			__onFail( "SOCKS5 failed: "+err );
		} else {
			__onConnect( this );
		}
	}
	
	function cleanup() {
		try {
			if( socket != null && socket.connected ) socket.close();
			if( server != null ) server.close();
		} catch( e : Dynamic ) { #if jabber_debug trace(e); #end }
	}
	
	#end
	
}
