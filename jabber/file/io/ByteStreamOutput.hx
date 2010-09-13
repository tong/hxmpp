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
package jabber.file.io;

import haxe.io.Bytes;
#if neko
import neko.net.Host;
import neko.net.Socket;
import neko.vm.Thread;
#elseif cpp
import cpp.net.Host;
import cpp.net.Socket;
import cpp.vm.Thread;
#elseif php
import php.net.Host;
import php.net.Socket;
#elseif nodejs
import js.Node;
typedef Socket = Stream;
#end

/**
	SOCKS5 bytestream output.
*/
class ByteStreamOutput extends ByteStreamIO  {
	
	public var __onConnect : ByteStreamOutput->Void;
	public var __onComplete : Void->Void;
	
	#if (neko||cpp||php)
	var server : Socket;
	#elseif nodejs
	var server : Server;
	#end
	var socket : Socket;
	var digest : String;
	
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
			} catch( e : Dynamic ) {
				__onFail( e );
				return;
			}
		}
		__onComplete();
		
		#end
	}
	
	#if (neko||cpp)
	
	function callbackConnect( err : String ) {
		( err == null ) ? __onConnect( this ) : __onFail( err );
	}
	
	function callbackSent( err : String ) {
		try socket.close() catch( e : Dynamic ) { #if JABBER_DEBUG trace(e); #end }
		try server.close() catch( e : Dynamic ) { #if JABBER_DEBUG trace(e); #end }
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
		var err : String = null;
		/* //TODO
		try {
			var r = c.input.read( 23 ).toString();
			jabber.util.FlashPolicy.allow( r, c, ip, port );
		} catch( e : Dynamic ) {
			trace(e);
		}
		*/
		try {
			if( !jabber.util.SOCKS5In.process( c.input, c.output, digest, ip, port ) ) {
				cb( "SOCKS5 failed" );
				return;
			}
			c.output.flush();
		} catch( e : Dynamic ) {
			err = e;
		}
		cb( err );
	}
	
	function t_send() {
		var socket : Socket = Thread.readMessage( true );
		var input : haxe.io.Input = Thread.readMessage( true );
		var size : Int = Thread.readMessage( true );
		var bufsize : Int = Thread.readMessage( true );
		var cb : String->Void = Thread.readMessage( true );
		var pos = 0;
		var err : String = null;
		while( pos != size ) {
			var remain = size-pos;
			var len = ( remain > bufsize ) ? bufsize : remain;
			var buf = Bytes.alloc( len );
			try {
				pos += input.readBytes( buf, 0, len );
				socket.output.write( buf );
			} catch( e : Dynamic ) {
				trace(e);
				err = e;
				break;
			}
		}
		cb( err );
	}
	
	#elseif nodejs
	
	function onConnect( s : Stream ) {
		socket = s;
		var socks5 = new jabber.util.SOCKS5In( socket, digest );
		socks5.run( host, port, onSOCKS5Complete );
	}
	
	function onSOCKS5Complete( err : String ) {
		if( err != null ) {
			__onFail( "SOCKS5 failed: "+err );
		} else {
			__onConnect( this );
		}
	}
	
	#end
	
}
