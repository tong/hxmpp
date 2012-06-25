/*
 * Copyright (c) 2012, tong, disktree.net
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
import jabber.data.io.IBInput;
import xmpp.IQ;

/**
	Incoming inband file transfer handler <a href="http://xmpp.org/extensions/xep-0047.html">XEP-0047: In-Band Bytestreams</a>
*/
class IBReciever extends DataReciever {
	
	var input : IBInput;
	
	public function new( stream : jabber.Stream, ?maxBlockSize : Int ) {
		super( stream, xmpp.file.IB.XMLNS );
	}
	
	public override function accept( yes : Bool, ?range : xmpp.file.Range ) {
		super._accept( yes, "open", range );
	}
	
	override function handleRequest( iq : IQ ) {
		
		var size = file.size;
		if( range != null ) {
			if( range.length != null ) size = range.length;
			else if( range.offset != null ) size -= range.offset;
		}
		
		input = new IBInput( stream, iq.from, sid, size );
		//input.__onConnect = onInit;
		input.__onProgress = onProgress;
		input.__onComplete = onComplete;
		input.__onFail = onFail;
		stream.sendPacket( IQ.createResult( iq ) );
	}
	
}
