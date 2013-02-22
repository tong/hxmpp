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
	Listens/Answers entity time requests.

	XEP 202 - EntityTime http://www.xmpp.org/extensions/xep-0202.html
*/
class EntityTimeListener {
	
	public var stream(default,null) : Stream;
	public var time(default,null) : xmpp.EntityTime;
	
	var c : PacketCollector;
	
	public function new( stream : Stream, ?tzo : String = "00:00" ) {
		if( !stream.features.add( xmpp.EntityTime.XMLNS ) )
			throw "entitytime listener already added";
		this.stream = stream;
		time = new xmpp.EntityTime( null, tzo );
		c = stream.collect( [new xmpp.filter.IQFilter(xmpp.EntityTime.XMLNS,xmpp.IQType.get,"time")], handleRequest, true );
	}
	
	public function dispose() {
		stream.removeCollector( c );
		stream.features.remove( xmpp.EntityTime.XMLNS );
	}
	
	function handleRequest( iq : xmpp.IQ ) {
		var r = xmpp.IQ.createResult( iq );
		time.utc = xmpp.DateTime.now();
		r.x = time;
		stream.sendPacket( r );	
	}
	
}
