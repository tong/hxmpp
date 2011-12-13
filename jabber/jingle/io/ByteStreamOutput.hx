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
package jabber.jingle.io;

import haxe.io.Bytes;
import jabber.util.SOCKS5Input;
#if neko
import neko.net.Host;
import neko.net.Socket;
import neko.vm.Thread;
#end

class ByteStreamOutput extends ByteStreamTransport {
	
	public var __onClientConnect : ByteStreamOutput->Void;
	public var __onProgress : Int->Void;
	
	#if (neko||cpp)
	var server : Socket;
	#end
	
	public function new( host : String, port : Int, bufsize : Int = 4096 ) {
		super( host, port );
		this.bufsize = bufsize;
	}
	
	public override function init() {
		
		#if JABBER_DEBUG
		trace( "Starting file transfer server ["+host+":"+port+"]" );
		#end
		
		#if (neko||cpp)
		server = new Socket();
		try server.bind( new Host( host ), port ) catch( e : Dynamic ) {
			__onFail( e );
			return;
		}
        server.listen( 1 );
        //__onConnect();
		var t = Thread.create( t_wait );
		t.sendMessage( Thread.current() );
		t.sendMessage( server );
		t.sendMessage( host );
		t.sendMessage( port );
		t.sendMessage( callbackConnect );
		
		#end
	}
	
	public function send( input : haxe.io.Input, size : Int ) {
		
		#if JABBER_DEBUG
		trace( "Transfering file [size:"+size+",bufsize:"+bufsize+"]" );
		#end
		
		#if (neko||cpp)
		socket = Thread.readMessage( false );
		if( socket == null ) {
			cleanup();
			__onFail( "client socket not connected" );
			return;
		}
		var t = Thread.create( t_send );
		t.sendMessage( socket );
		t.sendMessage( input );
		t.sendMessage( size );
		t.sendMessage( bufsize );
		t.sendMessage( __onProgress );
		t.sendMessage( callbackComplete );
		#end
	}
	
	#if (neko||cpp)
	
	function callbackConnect( e : String ) {
		if( e == null )
			__onClientConnect( this );
		else {
			cleanup();
			__onFail( e );
		}
	}
	
	function callbackComplete( e : String ) {
		cleanup();
		if( e == null )
			__onComplete();
		else
			__onFail( e );
	}
	
	function t_wait() {
		var main : Thread = Thread.readMessage ( true );
		var server : Socket = Thread.readMessage( true );
		var ip : String = Thread.readMessage( true );
		var port : Int = Thread.readMessage( true );
		var cb : String->Void = Thread.readMessage( true );
		var s : Socket = server.accept();
		main.sendMessage( s );
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
			try {
				socket.output.writeInput( input, len );
				pos += len;
				socket.output.flush();
			} catch( e : Dynamic ) {
				cb( e );
				return;
			}
			if( onProgress != null ) onProgress( pos );
		}
		cb( null );
	}
	
	function cleanup() {
		if( socket != null ) try socket.close() catch(e:Dynamic) { #if JABBER_DEBUG trace(e); #end }
		if( server != null ) try server.close() catch(e:Dynamic) { #if JABBER_DEBUG trace(e); #end }
	}
	
	#end
	
}
