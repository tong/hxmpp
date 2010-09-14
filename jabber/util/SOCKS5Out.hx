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
package jabber.util;

import haxe.io.Bytes;

#if (neko||cpp||php)
import haxe.io.BytesBuffer;
#if neko
import neko.net.Socket;
#elseif cpp
import cpp.net.Socket;
#elseif php
import php.net.Socket;
#end

/**
	<a href="http://www.faqs.org/rfcs/rfc1928.html">RFC 1928</a>
	SOCKS5 negotiation for outgoing socket connections (incoming filetransfers).<br/>
	This is not a complete implementation of the SOCKS5 protocol,<br/>
	just a subset fulfilling requirements in context of XMPP (datatransfers).
*/
class SOCKS5Out {
	
	public function new() {}
	
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
}


#elseif flash

import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.ProgressEvent;
import flash.events.SecurityErrorEvent;
import flash.utils.ByteArray;

private enum State {
	WaitResponse;
	WaitAuth;
}

class SOCKS5Out {
	
	var socket : Socket;
	var digest : String;
	var cb : String->Void;
	var state : State;
	var i : flash.utils.IDataInput;
	
	public function new() {}
	
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
}


#elseif nodejs

import js.Node;

private enum State {
	WaitResponse;
	WaitAuth;
}

class SOCKS5Out {
	
	var socket : Stream;
	var digest : String;
	var cb : String->Void;
	var state : State;
	
	public function new() {}
	
	public function run( socket : Stream, digest : String, cb : String->Void ) {
		this.socket = socket;
		this.digest = digest;
		this.cb = cb;
		state = WaitResponse;
		socket.on( Node.EVENT_STREAM_END, onError );
		socket.on( Node.EVENT_STREAM_ERROR, onError );
		socket.on( Node.EVENT_STREAM_DATA, onData );
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
		socket.removeAllListeners( Node.EVENT_STREAM_DATA );
		socket.removeAllListeners( Node.EVENT_STREAM_END );
		socket.removeAllListeners( Node.EVENT_STREAM_ERROR );
	}
}

#end
