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

import xmpp.IQ;

/**
	XEP-0012: Last Activity: http://xmpp.org/extensions/xep-0012.html
*/
class LastActivityListener {

	public dynamic function onRequest( jid : String ) : Null<Int> { return null; }
	
	public var stream(default,null) : Stream;
	
	var c : PacketCollector;
	
	public function new( stream : Stream ) {
		
		if( !stream.features.add( xmpp.LastActivity.XMLNS ) )
			throw "last activity listener already added";

		this.stream = stream;

		c = stream.collectPacket( [new xmpp.filter.IQFilter( xmpp.LastActivity.XMLNS, get, "query" )], handleRequest, true );
	}
	
	public function dispose() {
		if( c == null )
			return;
		stream.features.remove( xmpp.LastActivity.XMLNS );
		stream.removeCollector(c);
		c = null;
	}
	
	function handleRequest( iq : IQ ) {
		var time = onRequest( iq.from );
		//TODO if( time == null )
		var r = IQ.createResult( iq );
		r.x = new xmpp.LastActivity( time );
		stream.sendPacket( r );	
	}
	
}
