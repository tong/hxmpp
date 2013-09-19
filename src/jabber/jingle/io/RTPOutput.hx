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

#if neko

import neko.vm.Thread;
import net.rtp.Session;

/**
	Highly experimental!
*/
class RTPOutput extends RTPTransport {
	
	public function new( host : String, port : Int = 1935 ) {
		super( host, port );
	}
	
	public override function connect() {
		var t = Thread.create( t_run );
		t.sendMessage( Thread.current() );
		t.sendMessage( ip );
		t.sendMessage( port );
		t.sendMessage( sys.io.File.read('audio.wav',true) ); //TODO temp
		t.sendMessage( callbackDisconnect );
	}
	
	function callbackDisconnect( e : String ) {
		if( e == null ) {
			//TODO__onDisconnect();
		} else {
			__onFail(e);
		}
	}
	
	function t_run() {
		var main : Thread = Thread.readMessage ( true );
		var ip : String = Thread.readMessage( true );
		var port : Int = Thread.readMessage( true );
		var input : haxe.io.Input = Thread.readMessage( true );
		var cb : String->Void = Thread.readMessage( true );
		//TODO
		var rtp = new net.rtp.Session( SessionMode.sendonly, port, ip );
		var buf = Bytes.alloc( 160 );
		var i = 0;
		var user_ts = 0;
		var error : String = null;
		do {
			try {
				i = input.readBytes( buf, 0, 160 );
			} catch( e : haxe.io.Eof ) {
				trace(e);
				break;
			} catch( e : Dynamic ) {
				error = e;
				break;
			}
			rtp.sendWithTS( buf, i, user_ts );
			user_ts += 160;
		} while( i > 0 );
		net.rtp.Lib.statsDisplay();
		trace( net.rtp.Lib.getGlobalStats() );		
		rtp.destroy();
		cb( error );
	}
	
}

#end // neko
