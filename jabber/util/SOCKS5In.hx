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
import haxe.io.Input;
import haxe.io.Output;

/**
	<a href="http://www.faqs.org/rfcs/rfc1928.html">RFC 1928</a>
	This is not a complete implementation of the SOCKS5 protocol,<br/>
	just a subset fulfilling requirements in context of XMPP (datatransfers).
*/
class SOCKS5In {
	
	/**
		SOCKS5 negotiation for incoming socket connections.
		Returns true on negotiation success.
	*/
	public static function process( i : Input, o : Output, digest : String, ip : String, port : Int ) : Bool {

		trace( i.readByte() ); // 5 version
		var n = i.readByte(); // num auth methods
		trace( n );
		for( _ in 0...n ) trace( i.readByte() );
		
		o.writeByte( 5 );
		o.writeByte( 0 );
		
		trace( i.readByte() );
		trace( i.readByte() );
		trace( i.readByte() );
		trace( i.readByte() );
		var len = i.readByte();
		trace( len );
		var _digest = i.readString( len );
		trace( _digest );
		if( _digest != digest ) {
			trace( "Digest dos not match" );
			return false;
		}
		trace( i.readInt16() );
		
		o.writeByte( 5 );
		o.writeByte( 0 );
		o.writeByte( 0 );
		o.writeByte( 3 );
		
		o.writeByte( ip.length );
		o.writeString( ip );
		o.writeInt16( port );
		
		return true;
	}
}

#elseif nodejs

import js.Node;
import haxe.io.Bytes;
import haxe.io.BytesBuffer;

private enum State {
	WaitInit;
	WaitAuth;
}

class SOCKS5In {
	
	var socket : Stream;
	var digest : String;
	var cb : String->Void;
	var ip : String;
	var port : Int;
	var state : State;
	
	public function new( s : Stream, digest : String ) {
		this.socket = s;
		this.digest = digest;
		state = WaitInit;
	}
	
	public function run( ip : String, port : Int, cb : String->Void ) {
		this.ip = ip;
		this.port = port;
		this.cb = cb;
		socket.on( Node.EVENT_STREAM_END, onError );
		socket.on( Node.EVENT_STREAM_ERROR, onError );
		socket.on( Node.EVENT_STREAM_DATA, onData );
	}
	
	function onData( buf : Buffer ) {
		trace("onData ["+state+"] "+buf.length);
		
		switch( state ) {
		case WaitInit :
			//..check...
			var b = new haxe.io.BytesBuffer();
			b.addByte( 0x05 );
			b.addByte( 0x00 );
			socket.write( b.getBytes().getData() );
			state = WaitAuth;
			
		case WaitAuth :
			trace("<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
			
			var i = new haxe.io.BytesInput( Bytes.ofData( buf ) );
			trace( i.readByte() );
			trace( i.readByte() );
			trace( i.readByte() );
			trace( i.readByte() );
			var len = i.readByte();
			trace( len );
			var _digest = i.readString( len );
			trace( _digest );
			if( _digest != digest ) {
				trace( "Digest dos not match" );
				cb( "Digest dos not match" );
			}
			trace( i.readInt16() );
			
			var o = new haxe.io.BytesBuffer();
			
			o.addByte( 5 );
			o.addByte( 0 );
			o.addByte( 0 );
			o.addByte( 3 );
		
			o.addByte( ip.length );
			o.add( Bytes.ofString(ip) );
			//o.addByte( port );
			o.addByte( 0 );
			o.addByte( 0 );
			
			socket.write( o.getBytes().getData() );
			
			socket.removeAllListeners( Node.EVENT_STREAM_DATA );
			socket.removeAllListeners( Node.EVENT_STREAM_END );
			socket.removeAllListeners( Node.EVENT_STREAM_ERROR );
			
			cb( null );
		}
	}
	
	function onError() {
		trace("ERROR");	
	}
	
}

#end
