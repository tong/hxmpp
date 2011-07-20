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
package jabber.data.io;

import haxe.io.Bytes;
import jabber.stream.PacketCollector;
import jabber.util.Base64;
import xmpp.IQ;

/**
	Outgoing inband data transfer.
	<a href="http://xmpp.org/extensions/xep-0047.html">XEP-0047: In-Band Bytestreams</a><br/>
*/
class IBOutput extends IBIO {
	
	public var __onProgress : Int->Void;
	
	var reciever : String;
	var input : haxe.io.Input;
	var bufsize : Int;
	var iq : IQ;
	var collector : PacketCollector;
	
	public function new( stream : jabber.Stream, reciever : String, sid : String ) {
		super( stream, sid );
		this.reciever = reciever;
	}
	
	public function send( input : haxe.io.Input, size : Int, bufsize : Int ) {
		this.input = input;
		this.size = size;
		this.bufsize = bufsize;
		collector = stream.collect( [cast new xmpp.filter.PacketFromFilter( reciever ),
						 			 cast new xmpp.filter.IQFilter( xmpp.file.IB.XMLNS, xmpp.IQType.set, "close" )],
									handleIBClose );
		iq = new IQ( xmpp.IQType.set, null, reciever );
		bufpos = 0;
		sendNextPacket();
	}
	
	function handleIBClose( iq : IQ ) {
		if( active && bufpos == size ) {
			stream.sendPacket( IQ.createResult( iq ) );
			active = false;
			__onComplete();
		} else {
			stream.sendPacket( IQ.createError( iq, [new xmpp.Error( xmpp.ErrorType.cancel, "bad-request" )] ) );
			__onFail( "invalid IB transfer" );
		}
		stream.removeCollector( collector );
	}
	
	function sendNextPacket() {
		iq.id = stream.nextID()+"_ib_"+seq;
		var remain = size-bufpos;
		var len = ( remain > bufsize ) ? bufsize : remain;
		var buf = Bytes.alloc( len );
		bufpos += input.readBytes( buf, 0, len );
		__onProgress( bufpos );
		iq.properties = [xmpp.file.IB.createDataElement( sid, seq, Base64.encodeBytes( buf ) )];
		stream.sendIQ( iq, handleChunkResponse );
	}
	
	function handleChunkResponse( iq : IQ ) {
		switch( iq.type ) {
		case result :
			if( bufpos < size ) {
				seq++;
				sendNextPacket();
			} else {
				if( active ) {
					active = false;
					var iq = new IQ( xmpp.IQType.set, null, reciever );
					iq.x = new xmpp.file.IB( xmpp.file.IBType.close, sid );
					var me = this;
					stream.sendIQ( iq, function(r:xmpp.IQ) {
						switch( r.type ) {
						case result :
							me.__onComplete();
						case error :
							me.__onFail( iq.errors[0].condition );
						default : //
						}
					} );
				}
			}
		case error :
			__onFail( iq.errors[0].condition );
		default :
		}
	}
	
}
