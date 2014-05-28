/*
 * Copyright (c) disktree.net
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
package jabber.data.io;

import haxe.crypto.Base64;
import haxe.io.Bytes;
//import jabber.util.Base64;
import xmpp.filter.IQFilter;
import xmpp.IQ;

class IBInput extends IBIO {
	
	public var __onProgress : Bytes->Void;
	
	var initiator : String;
	var collector : PacketCollector;
	
	public function new( stream : jabber.Stream, initiator : String, sid : String, size : Int ) {
		super( stream, sid, size );
		this.initiator = initiator;
		bufpos = 0;
		seq = 0;
		active = true;
		var fromfilter : xmpp.PacketFilter = new xmpp.filter.PacketFromFilter( initiator );
		stream.collectPacket( [fromfilter,
						 new IQFilter( xmpp.file.IB.XMLNS, set, "close" )],
						 handleClose );
		collector = stream.collectPacket( [fromfilter,
						 			 new IQFilter( xmpp.file.IB.XMLNS, set, "data" )],
						 			 handleChunk, true );
	}
	
	function handleClose( iq : IQ ) {
		stream.removeCollector( collector );
		if( bufpos == size ) {
			stream.sendPacket( IQ.createResult( iq ) );
			if( active ) {
				active = false;
				__onComplete();
			}
		} else {
			active = false;
			__onFail( "ib datatransfer failed" );
			//..
		}
	}
	
	function handleChunk( iq : IQ ) {
		var ib = xmpp.file.IB.parse( iq.x.toXml() );
		if( ib.sid != sid ) {
			stream.removeCollector( collector );
			stream.sendPacket( IQ.createError( iq, [new xmpp.Error( cancel, "bad-request" )] ) );
			return;
		}
		if( ib.seq != seq ) {
			stream.removeCollector( collector );
			stream.sendPacket( IQ.createError( iq, [new xmpp.Error( cancel, "unexpected-request" )] ) );
			return;
		}
		seq++;
		var bytes = Base64.decode( ib.data );
		//var bytes = Base64.decodeBytes( ib.data );
		bufpos += bytes.length;
		stream.sendPacket( IQ.createResult( iq ) );
		__onProgress( bytes );
		if( bufpos == size ) {
			active = false;
			__onComplete();
		}
	}
	
}
