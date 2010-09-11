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
package jabber.file.io;

import haxe.io.Bytes;
import jabber.util.Base64;
import jabber.stream.PacketCollector;
import xmpp.filter.IQFilter;
import xmpp.IQ;
import xmpp.IQType;

// TODO cached/uncahched mode

class IBInput extends IBIO {
	
	public var __onComplete : Bytes->Void;
	//public dynamic function __onData( bytes : Bytes ) : Void;
	
	var initiator : String;
	var data : Bytes;
	var collector : PacketCollector;
	
	public function new( stream : jabber.Stream, initiator : String, sid : String, filesize : Int ) {
		super( stream, sid );
		this.initiator = initiator;
		data = Bytes.alloc( filesize );
		bufpos = 0;
		seq = 0;
		active = true;
		var fromfilter : xmpp.PacketFilter = new xmpp.filter.PacketFromFilter( initiator );
		stream.collect( [fromfilter,
						 new IQFilter( xmpp.file.IB.XMLNS, "close", IQType.set )],
						 handleClose );
		collector = stream.collect( [fromfilter,
						 			 cast new IQFilter( xmpp.file.IB.XMLNS, "data", IQType.set )],
						 			 handleChunk, true );
	}
	
	function handleClose( iq : IQ ) {
		trace("CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC");
		if( bufpos == data.length ) {
			stream.sendPacket( IQ.createResult( iq ) );
			if( active ) {
				active = false;
				__onComplete( data );
			}
		} else {
			active = false;
			__onFail( "ib failed" );
		}
	}
	
	function handleChunk( iq : IQ ) {
		var ib = xmpp.file.IB.parse( iq.x.toXml() );
		if( ib.sid != sid ) {
			//TODO send error
			
			return;
		}
		if( ib.seq != seq ) {
			//..
			return;
		}
		seq++;
		var bytes : Bytes = null;
		try {
			bytes = haxe.io.Bytes.ofString( Base64.decode( ib.data ) );
		} catch( e : Dynamic ) {
			trace(e);
			return;
		}
		trace( ib.data.length );
		trace( bytes.length );
		data.blit( bufpos, bytes, 0, bytes.length );
		bufpos += bytes.length;
		stream.sendPacket( IQ.createResult( iq ) );
		trace(bufpos +" // "+ data.length);
		if( bufpos == data.length ) {
			trace("COMPLETECOMPLETECOMPLETECOMPLETECOMPLETECOMPLETECOMPLETECOMPLETECOMPLETECOMPLETECOMPLETE");
			__onComplete( data );
			//TODO close ib
		} else {
			
		}
	}
	
}
