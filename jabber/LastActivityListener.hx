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
package jabber;

/**
	XEP-0012: Last Activity: http://xmpp.org/extensions/xep-0012.html
*/
class LastActivityListener {
	
	/** Seconds passed after last user activity */
	public var time : Int;
	public var stream(default,null) : Stream;
	
	var c : PacketCollector;
	
	public function new( stream : Stream, time : Int = 0 ) {
		if( !stream.features.add( xmpp.LastActivity.XMLNS ) )
			throw "last activity listener already added" ;
		this.stream = stream;
		this.time = time;
		c = stream.collect( [new xmpp.filter.IQFilter( xmpp.LastActivity.XMLNS, xmpp.IQType.get, "query" )], handleRequest, true );
	}
	
	public function dispose() {
		if( c == null )
			return;
		stream.features.remove( xmpp.LastActivity.XMLNS );
		stream.removeCollector(c);
		c = null;
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		var r = new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from );
		r.x = new xmpp.LastActivity( time );
		stream.sendPacket( r );	
	}
	
}
