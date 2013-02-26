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
package jabber.jingle.io;

import haxe.io.Bytes;
import jabber.util.SOCKS5Input;
#if neko
import sys.net.Host;
import sys.net.Socket;
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
		
		#if jabber_debug
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
		
		#if jabber_debug
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
		if( socket != null ) try socket.close() catch(e:Dynamic) { #if jabber_debug trace(e); #end }
		if( server != null ) try server.close() catch(e:Dynamic) { #if jabber_debug trace(e); #end }
	}
	
	#end
	
}
