/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
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
package jabber.data.io;

import haxe.io.Bytes;
import jabber.util.SOCKS5In;
#if neko
import neko.net.Host;
import neko.net.Socket;
import neko.vm.Thread;
#elseif cpp
import cpp.net.Host;
import cpp.net.Socket;
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
	public var __onComplete : Void->Void;
	
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
		
		#if JABBER_DEBUG
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
		
		#elseif php
		throw "Not implemented";
		/*
		server = new Socket();
		server.bind( new Host( host ), port );
		server.listen( 1 );
		//while( true ) {
			try {
				socket = server.accept();
			} catch( e : Dynamic ) {
				trace( e );
				__onFail( e );
				return;
			}
			//break;
		//}
		trace("CONNECTED...");
		*/
		
		#elseif nodejs
		server = Node.net.createServer( onConnect );
		server.listen( port, host );
		
		#elseif air
		server = new flash.net.ServerSocket();
		server = new ServerSocket();
		server.bind( port, host );
		server.addEventListener( ServerSocketConnectEvent.CONNECT, onConnect );
		//TODO...listeners
		server.listen( 1 );
		
		#end
	}
	
	public function send( input : haxe.io.Input, size : Int, bufsize : Int ) {
		
		#if JABBER_DEBUG
		trace( "Transfering file [size:"+size+",bufsize:"+bufsize+"]" );
		#end
		
		#if (neko||cpp)
		socket = Thread.readMessage( false );
		if( socket == null ) {
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
				socket.end();
				server.close();
				__onFail( e );
				return;
			}
		}
		socket.end();
		server.close();
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
				closeSockets();
				__onFail( e );
				return;
			}
		}
		closeSockets();
		__onComplete();
		
		#end
	}
	
	public function close() {
		trace("TODO force close unused bytestream transports");
	}
	
	
	#if (neko||cpp)
	
	function callbackConnect( err : String ) {
		if( err == null ) __onConnect( this );
		else {
			closeSockets();
			__onFail( err );
		}
	}
	
	function callbackSent( err : String ) {
		closeSockets();
		( err == null ) ? __onComplete() : __onFail( err );
	}
	
	function closeSockets() {
		if( socket != null ) try socket.close() catch( e : Dynamic ) { #if JABBER_DEBUG trace(e); #end }
		if( server != null ) try server.close() catch( e : Dynamic ) { #if JABBER_DEBUG trace(e); #end }
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
		try new SOCKS5In().run( c, digest ) catch( e : Dynamic ) {
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
		//var err : String = null;
		while( pos < size ) {
			var remain = size-pos;
			var len = ( remain > bufsize ) ? bufsize : remain;
			var buf = Bytes.alloc( len );
			try {
				pos += input.readBytes( buf, 0, len );
				socket.output.write( buf );
				socket.output.flush();
				onProgress( pos );
			} catch( e : Dynamic ) {
				trace(e);
				cb( e );
				return;
				//err = e;
				//break;
			}
		}
		cb( null );
	}
	
	
	#elseif nodejs
	
	function onConnect( s : Stream ) {
		socket = s;
		//socket.on( Node.EVENT_STREAM_DATA, onData );
		new SOCKS5In().run( socket, digest, onSOCKS5Complete );
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
			socket.end();
			server.close();
			__onFail( "SOCKS5 failed: "+err );
		} else {
			__onConnect( this );
		}
	}
	
	
	#elseif air
	
	function onConnect( e : ServerSocketConnectEvent ) {
		socket = e.socket;
		new SOCKS5In().run( socket, digest, onSOCKS5Complete );
	}
	
	function onSOCKS5Complete( err : String ) {
		if( err != null ) {
			closeSockets();
			__onFail( "SOCKS5 failed: "+err );
		} else {
			__onConnect( this );
		}
	}
	
	function closeSockets() {
		try {
			if( socket != null && socket.connected ) socket.close();
			if( server != null ) server.close();
		} catch( e : Dynamic ) { #if JABBER_DEBUG trace(e); #end }
	}
	
	#end
	
}
