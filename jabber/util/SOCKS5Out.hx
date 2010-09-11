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

#if (neko||cpp)
import haxe.io.Bytes;
import haxe.io.BytesBuffer;
import haxe.io.Input;
import haxe.io.Output;

/**
	<a href="http://www.faqs.org/rfcs/rfc1928.html">RFC 1928</a>
	This is not a complete implementation of the SOCKS5 protocol,<br/>
	just a subset fulfilling requirements in context of XMPP (datatransfers).
*/
class SOCKS5Out {
	
	// TODO bufferd!
	
	/**
		SOCKS5 negotiation for outgoing socket connections
	*/
	public static function process( i : Input, o : Output, digest : String ) {
		
		o.writeByte( 0x05 );
		o.writeByte( 0x01 ); // num auth methods
		o.writeByte( 0x00 ); // no auth
		o.flush();
		
		trace( i.readByte() ); // 5
		trace( i.readByte() ); // 0
		
		o.writeByte( 0x05 );
		o.writeByte( 0x01 );
		o.writeByte( 0x00 );
		o.writeByte( 0x03 );
		o.writeByte( digest.length );
		o.writeString( digest );
		o.writeByte( 0x00 ); // TODO port
		o.writeByte( 0x00 ); // TODO port
		o.flush();
		
		trace( i.readByte() ); // 5
		trace( i.readByte() ); // 0
		trace( i.readByte() ); // 0
		trace( i.readByte() ); // 3
		var len = i.readByte();
		trace(len); // hash/ip length
		trace( i.readString( len ) ); // hash/ip
		trace( i.readInt16() ); // 0
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
	//WaitDigest( len : Int );
}

/**
	<a href="http://www.faqs.org/rfcs/rfc1928.html">RFC 1928</a>
*/
class SOCKS5Out {
	
	var cb : String->Void;
	var socket : Socket;
	var digest : String;
	var state : State;
	var i : flash.utils.IDataInput;
	var o : flash.utils.IDataOutput;
	
	public function new( socket : Socket, digest : String ) {
		this.socket = socket;
		this.digest = digest;
		i = socket;
		o = socket;
	}
	
	public function run( cb : String->Void ) {
		this.cb = cb;
		state = WaitResponse;
		socket.addEventListener( ProgressEvent.SOCKET_DATA, onData );
		socket.addEventListener( Event.CLOSE, onError );
		socket.addEventListener( IOErrorEvent.IO_ERROR, onError );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, onError );
		var b = new ByteArray();
		b.writeByte( 0x05 );
		b.writeByte( 0x01 );
		b.writeByte( 0x00 );
		o.writeBytes( b );
		socket.flush();
	}
	
	function onData( e : ProgressEvent ) {
		switch( state ) {
		case WaitResponse :
			trace( i.readByte() );
			trace( i.readByte() );
			var b = new ByteArray();
			b.writeByte( 0x05 );
			b.writeByte( 0x01 );
			b.writeByte( 0x00 );
			b.writeByte( 0x03 );
			b.writeByte( digest.length );
			b.writeUTFBytes( digest );
			b.writeByte( 0x00 );
			b.writeByte( 0x00 );
			o.writeBytes( b );
			socket.flush();
			state = WaitAuth;
		case WaitAuth :
			trace( i.readByte() );
			trace( i.readByte() );
			trace( i.readByte() );
			trace( i.readByte() );
			var l = i.readByte();
			trace(l);
			trace( i.readUTFBytes(l) );
			trace( i.readShort() ); // port
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, onData );
			removeSocketListeners();
			cb( null );
		}
	}
	
	function onError( e : Event ) {
		removeSocketListeners();
		cb( "SOCKS5 error" );
	}
	
	function removeSocketListeners() {
		socket.removeEventListener( Event.CLOSE, onError );
		socket.removeEventListener( IOErrorEvent.IO_ERROR, onError );
		socket.removeEventListener( SecurityErrorEvent.SECURITY_ERROR, onError );
	}
	
}

#end
