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
package jabber;

import jabber.util.Base64;

/**
	Listens for 'Bits Of Binary' requests.

	XEP-0231: Bits of Binary: http://xmpp.org/extensions/xep-0231.html
*/
class BOBListener {
	
	/**
		Callback handler for BOB requests: JID->CID->BOB
	*/
	public var onRequest : String->String->xmpp.BOB;
	
	public var stream(default,null) : jabber.Stream;

	var c : PacketCollector;

	public function new( stream : jabber.Stream, onRequest : String->String->xmpp.BOB ) {
		if( !stream.features.add( xmpp.BOB.XMLNS ) )
			throw "bob listener already added";
		this.stream = stream;
		this.onRequest = onRequest;
		c = stream.collect( [new xmpp.filter.IQFilter(xmpp.BOB.XMLNS,xmpp.IQType.get,'data')], handleRequest, true );
	}
	
	public function dispose() {
		stream.removeCollector( c );
		stream.features.remove( xmpp.BOB.XMLNS );
	}

	function handleRequest( iq : xmpp.IQ ) {
		var _bob = xmpp.BOB.parse( iq.x.toXml() );
		var _cid = xmpp.BOB.getCIDParts( _bob.cid );
		var bob : xmpp.BOB = onRequest( iq.from, _cid[1] );
		if( bob == null ) {
			//trace("NO BOB FOUND");
			//TODO check XEP for updates
			//.??
		} else {
			//var r = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from );
			var r = xmpp.IQ.createResult( iq );
			// encode here?
			bob.data =  new haxe.crypto.BaseCode( haxe.io.Bytes.ofString( Base64.CHARS ) ).encodeString( bob.data );
			r.x = bob;
			stream.sendPacket( r );
		}
	}
	
}
