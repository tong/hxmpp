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
package jabber.stream;

import jabber.stream.PacketCollector;

/**
	Abstract base for top level packet listeners ( jabber.PresenceListener, jabber.MessageListener ).
*/
class PacketListener<T:xmpp.Packet> {
	
	/** Packet recieved callback */
	public dynamic function onPacket( p : T ) {}
	
	/** Activates/Deactivates packet collecting */
	public var listen(default,setListening) : Bool;
	
	/** The collector for this listener */
	public var collector(default,null) : PacketCollector;
	
	public var stream(default,null) : jabber.Stream;
	
	function new( stream : jabber.Stream, handler : T->Void, packetType : xmpp.PacketType, listen : Bool ) {
		this.stream = stream;
		this.onPacket = handler;
		collector = new PacketCollector( [new xmpp.filter.PacketTypeFilter(packetType)], handlePacket, true );
		setListening( listen );
	}
	
	function setListening( v : Bool ) : Bool {
		return ( listen = v ) ?
			stream.addCollector( collector ) :
			stream.removeCollector( collector );
	}
	
	// override me if you want
	function handlePacket( p : T ) {
		this.onPacket( p );
	}
	
}
