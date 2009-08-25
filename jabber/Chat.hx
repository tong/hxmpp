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
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketFromFilter;

/**
	Represents a chat conversation between two jabber clients.
*/
class Chat {
	
	public dynamic function onMessage( c : Chat ) : Void;
	
	public var stream(default,null) : Stream;
	public var peer(default,null) : String;
	public var threadID(default,setThreadID) : String;
	public var lastMessage(default,null) : xmpp.Message;
	
	var c : PacketCollector;
	var m : xmpp.Message;
	
	// TODO myJid? needed ?
	public function new( stream : Stream, myJid : String, peer : String,
					 	 ?threadID : String ) {
		
		m = new xmpp.Message( peer, null, null, xmpp.MessageType.chat, threadID, stream.jidstr );
		
		this.stream = stream;
		this.peer = peer;
		this.threadID = threadID;
		
		var mf : xmpp.PacketFilter = new xmpp.filter.MessageFilter( xmpp.MessageType.chat );
		var ff : xmpp.PacketFilter = new xmpp.filter.PacketFromContainsFilter( peer );
		c = new PacketCollector( [ mf, ff ], handleMessage, true );
		stream.addCollector( c );
	}
	
	
	function setThreadID( id : String ) : String {
		threadID = m.thread = id;
		return id;
	}
	
	/**
		Sends a chat message to the peer.
	*/
	public function speak( t : String ) : xmpp.Message {
		m.body = t;
		return stream.sendPacket( m );
	}
	
	/**
		Removes the collector from this stream.
	*/
	public function destroy() {
		stream.removeCollector( c );
	}
	
	/**
		Handles incoming message.
	*/	
	public function handleMessage( m : xmpp.Message ) {
		#if JABBER_DEBUG
		if( m.type != xmpp.MessageType.chat ) {
			trace( "Chats can only handle chat-type messages" );
			return;
		}
		#end
		lastMessage = m;
		onMessage( this );
	}
	
}
