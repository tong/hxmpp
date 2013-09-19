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

#if sys
import haxe.io.BytesBuffer;
import sys.net.Socket;
#elseif nodejs
import js.Node;
#elseif flash
import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.utils.ByteArray;
#end

#if (nodejs||flash)
private enum State {
	WaitResponse;
	WaitAuth;
}
#end

/**
	SOCKS5 negotiation for outgoing socket connections (incoming filetransfers).

	This is not a complete implementation of the SOCKS5 protocol, 
	just a subset for requirements in context of XMPP (datatransfers).

	http://www.faqs.org/rfcs/rfc1928.html">RFC 1928
*/
class SOCKS5Output {
	
	public function new() {}
	
	#if sys
	
	public function run( socket : Socket, digest : String ) {
		
		var i = socket.input;
		
		var b = new BytesBuffer();
		b.addByte( 0x05 );
		b.addByte( 0x01 );
		b.addByte( 0x00 );
		socket.output.write( b.getBytes() );
		
		i.readByte(); // 0x05
		i.readByte(); // 0x00
		
		socket.output.write( SOCKS5.createOutgoingMessage( 1, digest ) );
		
		i.readByte(); // 0x05
		i.readByte(); // 0x00
		i.readByte(); // 0x00
		i.readByte(); // 0x03
		i.readString( i.readByte() ); // digest
		i.readInt16();
	}
	
	#elseif flash
	
	var socket : Socket;
	var digest : String;
	var cb : String->Void;
	var state : State;
	var i : flash.utils.IDataInput;
	
	public function run( socket : Socket, digest : String, cb : String->Void ) {
		
		this.socket = socket;
		this.digest = digest;
		this.cb = cb;
		i = socket;

		state = WaitResponse;
		socket.addEventListener( ProgressEvent.SOCKET_DATA, onData );
		socket.addEventListener( Event.CLOSE, onError );
		socket.addEventListener( IOErrorEvent.IO_ERROR, onError );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onError );
		
		var b = new ByteArray();
		b.writeByte( 0x05 );
		b.writeByte( 0x01 );
		b.writeByte( 0x00 );
		socket.writeBytes( b );
		socket.flush();
	}
	
	function onData( e : ProgressEvent ) {
		switch( state ) {
		case WaitResponse :
			i.readByte();
			i.readByte();
			socket.writeBytes( SOCKS5.createOutgoingMessage( 1, digest ).getData() );
			socket.flush();
			state = WaitAuth;
		case WaitAuth :
			i.readByte(); // 0x05
			i.readByte(); // 0x00
			i.readByte(); // 0x00
			i.readByte(); // 0x03
			i.readUTFBytes( i.readByte() ); // digest
			i.readShort();
			removeSocketListeners();
			cb( null );
		}
	}
	
	function onError( e : Event ) {
		removeSocketListeners();
		cb( "SOCKS5 error" );
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
		
		state = WaitResponse;
		socket.on( Node.STREAM_END, onError );
		socket.on( Node.STREAM_ERROR, onError );
		socket.on( Node.STREAM_DATA, onData );
		socket.write( "\x05\x01"+String.fromCharCode(0) );
	}
	
	function onData( buf : Buffer ) {
		switch( state ) {
		case WaitResponse :
			socket.write( SOCKS5.createOutgoingMessage( 1, digest ).getData() );
			state = WaitAuth;
		case WaitAuth :
			var i = new haxe.io.BytesInput( Bytes.ofData( buf ) );
			i.readByte();
			i.readByte();
			i.readByte();
			i.readByte();
			i.readString( i.readByte() ); // digest
			i.readInt16();
			removeSocketListeners();
			cb( null );
		}
	}
	
	function onError() {
		removeSocketListeners();
		cb( "SOCKS5 failed" );
	}
	
	function removeSocketListeners() {
		socket.removeAllListeners( Node.STREAM_DATA );
		socket.removeAllListeners( Node.STREAM_END );
		socket.removeAllListeners( Node.STREAM_ERROR );
	}
	
	#end
}
