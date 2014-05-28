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

import haxe.io.Bytes;
import haxe.crypto.Base64;
import xmpp.IQ;

/**
	Outgoing inband data transfer.
	
	XEP-0047: In-Band Bytestreams (http://xmpp.org/extensions/xep-0047.html)
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
		var filters : Array<xmpp.PacketFilter> = [ new xmpp.filter.PacketFromFilter( reciever ),
						 new xmpp.filter.IQFilter( xmpp.file.IB.XMLNS, xmpp.IQType.set, "close" )];
		collector = stream.collectPacket( filters, handleIBClose );
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
			stream.sendPacket( IQ.createError( iq, [new xmpp.Error( cancel, "bad-request" )] ) );
			__onFail( "invalid ib transfer" );
		}
		stream.removeCollector( collector );
	}
	
	function sendNextPacket() {
		iq.id = stream.nextId()+"_ib_"+seq;
		var remain = size-bufpos;
		var len = ( remain > bufsize ) ? bufsize : remain;
		var buf = Bytes.alloc( len );
		bufpos += input.readBytes( buf, 0, len );
		__onProgress( bufpos );
		iq.properties = [xmpp.file.IB.createDataElement( sid, seq, Base64.encode( buf ) )];
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
