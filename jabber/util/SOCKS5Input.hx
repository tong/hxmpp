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
package jabber.util;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;

#if sys
import sys.net.Socket;
#end

#if nodejs
import js.Node;
#elseif air
#if flash
import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.utils.ByteArray;
import flash.utils.IDataInput;
#elseif js
import air.Socket;
import air.Event;
import air.IOErrorEvent;
import air.ProgressEvent;
import air.SecurityErrorEvent;
import air.ByteArray;
import air.IDataInput;
#end
#end

private enum State {
	WaitInit;
	WaitResponse;
}

/**
	SOCKS5 negotiation for incoming socket connections (outgoing datatransfers).
	
	This is not a complete implementation of the SOCKS5 protocol, 
	just a subset for requirements in context of XMPP (datatransfers).
	
	http://www.faqs.org/rfcs/rfc1928.html">RFC 1928
*/
class SOCKS5Input {
	
	public function new() {}
	
	#if sys
	
	/**
		SOCKS5 negotiation for incoming socket connections (outgoing datatransfers).
	*/
	public function run( socket : Socket, digest : String ) {
		
		var i = socket.input;
		var o = socket.output;
		
		if( i.readByte() != 0x05 ) // 0x05
			throw "invalid SOCKS5";
		for( _ in 0...i.readByte() )
			i.readByte();
		
		var b = new BytesBuffer();
		b.addByte( 0x05 );
		b.addByte( 0x00 );
		o.write( b.getBytes() );
		
		i.readByte();
		i.readByte();
		i.readByte();
		i.readByte();
		if( i.readString( i.readByte() ) != digest )
			throw "SOCKS5 digest does not match";
		i.readInt16();
		
		o.write( SOCKS5.createOutgoingMessage( 0, digest ) );
		o.flush();
	}
	
	
	#elseif flash
	
	var socket : Socket;
	var digest : String;
	var cb : String->Void;
	var state : State;
	var i : IDataInput;
	
	public function run( socket : Socket, digest : String, cb : String->Void ) {
		
		this.socket = socket;
		this.digest = digest;
		this.cb = cb;
		i = socket;
		
		state = WaitInit;
		socket.addEventListener( ProgressEvent.SOCKET_DATA, onData );
		socket.addEventListener( Event.CLOSE, onError );
		socket.addEventListener( IOErrorEvent.IO_ERROR, onError );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onError );
	}
	
	function onData( e : ProgressEvent ) {
		#if jabber_debug trace( 'SOCKS5 '+state, 'debug' ); #end
		switch( state ) {
		case WaitInit :
			i.readByte(); // 0x05
			for( _ in 0...i.readByte() ) i.readByte();
			var b = new ByteArray();
			b.writeByte( 0x05 );
			b.writeByte( 0x00 );
			socket.writeBytes( b );
			socket.flush();
			state = WaitResponse;
		case WaitResponse :
			i.readByte();
			i.readByte();
			i.readByte();
			i.readByte();
			if( i.readUTFBytes( i.readByte() ) != digest ) {
				cb( "SOCKS5 digest does not match" );
				return;
			}
			i.readShort();
			socket.writeBytes( SOCKS5.createOutgoingMessage( 0, digest ).getData() );
			removeSocketListeners();
			cb( null );
		}
	}
	
	function onError( e : Event ) {
		removeSocketListeners();
		cb( "SOCKS5 error "+e );
	}
	
	function removeSocketListeners() {
		socket.removeEventListener( ProgressEvent.SOCKET_DATA, onData );
		socket.removeEventListener( Event.CLOSE, onError );
		socket.removeEventListener( IOErrorEvent.IO_ERROR, onError );
		socket.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onError );
	}
	
	
	#elseif nodejs
	
	var socket : Stream;
	var digest : String;
	var cb : String->Void;
	var state : State;
	
	public function run( socket : Stream, digest : String, cb : String->Void ) {
		
		this.socket = socket;
		this.digest = digest;
		this.cb = cb;
		
		state = WaitInit;
		socket.on( Node.STREAM_END, onError );
		socket.on( Node.STREAM_ERROR, onError );
		socket.on( Node.STREAM_DATA, onData );
	}
	
	function onData( buf : Buffer ) {
		switch( state ) {
		case WaitInit :
			var b = new haxe.io.BytesBuffer();
			b.addByte( 0x05 );
			b.addByte( 0x00 );
			socket.write( b.getBytes().getData() );
			state = WaitResponse;
			
		case WaitResponse :
			var i = new haxe.io.BytesInput( Bytes.ofData( buf ) );
			i.readByte();
			i.readByte();
			i.readByte();
			i.readByte();
			if( i.readString( i.readByte() ) != digest ) {
				cb( "SOCKS5 digest does not match" );
				return;
			}
			i.readInt16();
			socket.write( SOCKS5.createOutgoingMessage( 0, digest ).getData() );
			removeSocketListeners();
			cb( null );
		}
	}
	
	function onError() {
		removeSocketListeners();
		cb( "SOCKS5 negotiation socket error" );
	}
	
	function removeSocketListeners() {
		socket.removeAllListeners( Node.STREAM_DATA );
		socket.removeAllListeners( Node.STREAM_END );
		socket.removeAllListeners( Node.STREAM_ERROR );
	}
	
	#end
	
}
