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
	
	#if (neko||cpp)
	var server : Socket;
	var socket : Socket;
	#elseif nodejs
	var server : Server;
	#end
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
		var h = new Host( host );
		try {
			server.bind( h, port );
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
//		server = Node.net.createServer( onConnect );
//		server.listen( port, host );
		
		#end
	}
	
	public function write( input : haxe.io.Input, size : Int, bufsize : Int ) {
		
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
		
		/*
		#elseif nodejs
		try {
			var b = haxe.io.Bytes.alloc( untyped input.size );
			input.readBytes( b, 0, b.length );
			stream.write( b.getData() );
			stream.end();
		} catch( e : Dynamic ) {
			trace(e);
			return;
		}
		__onComplete();
		*/
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
		while( true ) {
			c = server.accept();
			main.sendMessage( c );
			break;
		}
		var err : String = null;
		try {
			var _ip =  new Host(ip).ip;
			if( !jabber.util.SOCKS5In.process( c.input, c.output, _ip, port, digest ) ) {
				cb( "SOCKS5 failed" );
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
			var buf =  Bytes.alloc( len );
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
	
	/*
	#elseif nodejs
	
	var stream : Stream;
	
	function onConnect( s : Stream ) {
		stream = s;
	//	stream.setEncoding( Node.BINARY );
		stream.addListener( Node.EVENT_STREAM_DATA, onData );
		stream.addListener( Node.EVENT_STREAM_CLOSE, function(){trace("DISCONNECTED");} );
		stream.addListener( Node.EVENT_STREAM_ERROR, function(){trace("ERROR");} );
	}
	
	function onData( buf : Buffer ) {
		//trace("SOCKS5 "+socksState );
		switch( socksState ) {
			
		case WaitInit :
			//stream.write( "\x05\x01" );
			//trace( buf[1] );
			
			stream.write( "\x05"+String.fromCharCode(0) );
			//stream.write( "\x05"+String.fromCharCode(0) );
			socksState = WaitResponse;
			
		case WaitResponse :	
			
			var t = buf.toString( Node.UTF8 );
			var _digest = t.substr( 5, t.length-7 );
			if( _digest != digest ) {
				__onFail( "SOCKS5 digest error" );
				return;
			}
			
			stream.write( "\x05" );
			stream.write( String.fromCharCode(0) );
			stream.write( String.fromCharCode(0) );
			stream.write( "\x01" );
			
			stream.write( "\x127" );
			stream.write( String.fromCharCode(0) );
			stream.write( String.fromCharCode(0) );
			stream.write( "\x01" );
			
			
			var b = Node.newBuffer( 1, Node.BINARY );
			b.write( Std.string( port ) );
			stream.write( b );
			
			__onConnect( this );
		}
	}
	*/
	
	#end
	
}
