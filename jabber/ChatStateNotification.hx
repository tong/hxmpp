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

import xmpp.MessageType;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketPropertyFilter;

/**
	Extension for communicating the status of a user in a chat session.

	                o (start)
	                |
	                |
	INACTIVE <--> ACTIVE <--> COMPOSING <--> PAUSED
	    |                                       |
	    |                                       |
	    +---<---<---<---<---<---<---<---<---<---+

	XEP-0085: Chat State Notifications: http://xmpp.org/extensions/xep-0085.html
*/
class ChatStateNotification {
	
	public dynamic function onState( jid : String, state : xmpp.ChatState ) {}
	
	/** The chat state to intercept message packets with */
	public var state : xmpp.ChatState;
	public var stream(default,null) : Stream;
	
	var collector : PacketCollector;
	
	public function new( stream : jabber.Stream ) {
		
		//if( !stream.features.add( xmpp.ChatStateNotification.XMLNS ) )
		//	throw "chatstate listener already added";
		stream.features.add( xmpp.ChatStateNotification.XMLNS );
		
		this.stream = stream;
		var filters : Array<xmpp.PacketFilter> = [new MessageFilter(MessageType.chat),new PacketPropertyFilter(xmpp.ChatStateNotification.XMLNS)];
		collector = stream.collect( filters, handleMessage, true );
		stream.addInterceptor( this );
	}
	
	public function dispose() {
		stream.removeCollector( collector );
		stream.removeInterceptor( this );
	}
	
	/**
		Force send chat state in (standalone) notification message.
	*/
	public function send( to : String, state : xmpp.ChatState ) : xmpp.Message {
		var m = new xmpp.Message( to );
		xmpp.ChatStateNotification.set( m, state );
		stream.sendData( m.toString() );
		return m;
	}
	
	public function interceptPacket( p : xmpp.Packet ) : xmpp.Packet {
		if( p._type != xmpp.PacketType.message || state == null )
			return p;
		xmpp.ChatStateNotification.set( untyped p, state );
		return p;
	}
	
	function handleMessage( m : xmpp.Message ) {
		onState( m.from, xmpp.ChatStateNotification.get( m ) );
	}
	
}
