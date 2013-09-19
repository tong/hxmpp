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

#if neko

import haxe.io.Bytes;
import neko.vm.Thread;
import net.rtp.Session;

/**
	Highly experimental!
*/
class RTPInput extends RTPTransport {
	
	public var __onData : Bytes->Void;
	
	var recieving : Bool;
	
	public function new( ip : String, port : Int ) {
		super( ip, port );
		recieving = false;
	}
	
	public override function init() {
		trace("INIT.-.............................");
		recieving = true;
		var t = Thread.create( t_read );
		t.sendMessage( Thread.current() );
		t.sendMessage( ip );
		t.sendMessage( port );
		t.sendMessage( __onData );
		t.sendMessage( isRecieving );
	}
	
	public override function close() {
		recieving = false;
	}
	
	function isRecieving() : Bool {
		return recieving;
	}
	
	function t_read() {
		
		var main : Thread = Thread.readMessage ( true );
		var ip : String = Thread.readMessage( true );
		var port : Int = Thread.readMessage( true );
		var onData : Bytes->Void = Thread.readMessage( true );
		var _isRecieving : Void->Bool = Thread.readMessage( true );
		
		var rtp = new Session( SessionMode.recvonly, port, ip );
		var buf = haxe.io.Bytes.alloc( 160 );
		var have_more : Bool;
		var ts = 0;
		var stream_received = false;
		
		while( _isRecieving() ) {
			have_more = true;
			while( have_more ) {
				var r = rtp.recvWithTS( buf, 160, ts );
				have_more = r.more;// > 0;
				if( r.err > 0 ) stream_received = true;
				if( stream_received && ( r.err > 0 ) ) {
					//trace( "err: "+r.err+", buflen: "+buf.length );
					onData( buf );
				}
			}
			ts += 160;
		}
	}
	
	public static inline function ofCandidate( x : Xml ) : RTPInput {
		return new RTPInput( x.get( "ip" ), Std.parseInt( x.get( "port" ) ) );
	}
	
}
/*
#elseif droid

class RTPInput extends RTPTransport {
}
*/

#end
