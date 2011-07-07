/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package jabber;

import jabber.stream.PacketCollector;
import xmpp.MessageType;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketPropertyFilter;

/**
	<a href="http://xmpp.org/extensions/xep-0085.html">XEP-0085: Chat State Notifications</a><br/>
	Extension for communicating the status of a user in a chat session.
*/
class ChatStateNotification {
	
	public dynamic function onState( jid : String, state : xmpp.ChatState ) {}
	
	public var stream(default,null) : Stream;
	public var state : xmpp.ChatState;
	
	var collector : PacketCollector;
	
	public function new( stream : jabber.Stream ) {
		if( !stream.features.add( xmpp.ChatStateNotification.XMLNS ) )
			throw "chatstate listener already added";
		this.stream = stream;
		collector = stream.collect( [cast new MessageFilter(MessageType.chat),
									 cast new PacketPropertyFilter(xmpp.ChatStateNotification.XMLNS)
									], handleMessage, true );
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
