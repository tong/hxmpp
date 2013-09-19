/*
 * Copyright (c) 2012, disktree.net
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
package jabber.data;

import haxe.io.Bytes;
import jabber.util.Base64;
import jabber.data.io.IBOutput;
import xmpp.IQ;

/**
	Outgoing in-band file transfer negotiator
	<a href="http://xmpp.org/extensions/xep-0047.html">XEP-0047: In-Band Bytestreams</a>
	Data is broken down into smaller chunks and transported in-band over XMPP.
	Use only as a last resort. SOCKS5 Bytestreams will almost always be preferable.
*/
class IBTransfer extends DataTransfer {
	
	public static var defaultBufSize = 1<<12; //1<<14; //16384
	
	var transport : IBOutput;
	
	public function new( stream : jabber.Stream, reciever : String,
						 ?bufsize : Int ) {
		if( bufsize == null ) bufsize = defaultBufSize;
		super( stream, xmpp.file.IB.XMLNS, reciever, bufsize );
	}
	
	public override function init( input : haxe.io.Input, sid : String, file : xmpp.file.File ) {
		super.init( input, sid, file );
		var iq = new IQ( xmpp.IQType.set, null, reciever, stream.jid.toString() );
		iq.x = new xmpp.file.IB( xmpp.file.IBType.open, sid, bufsize );
		stream.sendIQ( iq, handleRequestResponse );
	}
	
	function sendRequest() {
		var iq = new IQ( xmpp.IQType.set, null, reciever, stream.jid.toString() );
		iq.x = new xmpp.file.IB( xmpp.file.IBType.open, sid, bufsize );
		stream.sendIQ( iq, handleRequestResponse );
	}
	
	function handleRequestResponse( iq : IQ ) {
		switch( iq.type ) {
		case result :
			transport = new IBOutput( stream, reciever, sid );
			transport.__onProgress = onProgress;
			transport.__onComplete = onComplete;
			transport.__onFail = handleTransportFail;
			//onInit( this );
			transport.send( input, file.size, bufsize );
		case error :
			onFail( iq.errors[0].condition );
		default : //
		}
	}
	
}
