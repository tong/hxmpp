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
import jabber.data.io.ByteStreamInput;
//import jabber.io.ByteStreamInput;
import jabber.util.SHA1;
import xmpp.IQ;

/**
	Incoming bytestream file transfer
	<a href="http://xmpp.org/extensions/xep-0065.html">XEP-0065: SOCKS5 Bytestreams.</a>
*/
class ByteStreamReciever extends DataReciever {
	
	var bytestream : xmpp.file.ByteStream;
	var bytestreamIndex : Int;
	var host : xmpp.file.ByteStreamHost;
	var digest : String;
	var iq : IQ;
	var input : ByteStreamInput;
	
	public function new( stream : jabber.Stream ) {
		super( stream, xmpp.file.ByteStream.XMLNS );
	}
	
	public override function accept( yes : Bool, ?range : xmpp.file.Range ) {
		super._accept( yes, "query", range );
	}
	
	override function handleRequest( iq : IQ ) {
		this.iq = iq;
		bytestream = xmpp.file.ByteStream.parse( iq.x.toXml() );
		bytestreamIndex = 0;
		digest = SHA1.encode( sid+iq.from+stream.jid.toString() );
		connect();
	}
	
	function connect() {
		host = bytestream.streamhosts[bytestreamIndex];
		input = new ByteStreamInput( host.host, host.port );
		input.__onConnect = handleTransferConnect;
		input.__onProgress = onProgress;
		input.__onComplete = onComplete;
		input.__onFail = handleTransferFail;
		var size = file.size;
		if( range != null ) {
			if( range.length != null ) size = range.length;
			else if( range.offset != null ) size -= range.offset;
		}
		//TODO:
		//input.init( digest, size );
		input.connect( digest, size );
	}
	
	function handleTransferConnect() {
		#if jabber_debug trace( "Bytestream connected ["+host.host+":"+host.port+"]" ); #end
		var r = IQ.createResult( iq );
		var bs = new xmpp.file.ByteStream( sid );
		bs.streamhost_used = host.jid;
		r.x = bs;
		stream.sendPacket( r );
	}
	
	function handleTransferFail( info : String ) {
		bytestreamIndex++;
		if( bytestreamIndex < bytestream.streamhosts.length ) {
			connect();
		} else {
			stream.sendPacket( IQ.createError( iq, [new xmpp.Error( xmpp.ErrorType.cancel, "item-not-found" )] ) );
		}
	}
	
}
