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

import xmpp.MessageType;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketFieldFilter;


//TODO where do i listen ?????

/**
	Extension for communicating the status of a user in a chat session.<br>
	<a href="http://xmpp.org/extensions/xep-0085.html">XEP-0085: Chat State Notifications.</a><br/>
*/
class ChatStateNotification {
	
	/**
		The current state of this chat.<br>
		If not null, messages sent to the peer jid of this chat will be intercepted with the state notification.
	*/
	public var state : xmpp.ChatState;
	public var chat(default,setChat) : Chat;
	public var featureName(default,null) : String; // ?? wtf
	
	var f_message : MessageFilter;
	var f_to : PacketFieldFilter;
	var m : xmpp.Message;
	
	
	public function new( chat : Chat ) {
		
		// TODO if( chat == null ) throw 
		
		m = new xmpp.Message( MessageType.chat );
		f_message = new MessageFilter( MessageType.chat );
		f_to = new PacketFieldFilter( "to", chat.peer );
		
		featureName = xmpp.ChatStateExtension.XMLNS; //TODO ?? wtf
		chat.stream.features.add( xmpp.ChatStateExtension.XMLNS );
		
		setChat( chat );
		
		chat.stream.addInterceptor( this );
	}
	
	
	function setChat( c : Chat ) : Chat {
		if( c == chat ) return c;
		m.to = c.peer;
		return chat = c;
	}
	
	
	/**
		Internal.
	*/
	public function interceptPacket( p : xmpp.Packet ) : xmpp.Packet {
		if( chat == null ) {
			chat.stream.removeInterceptor( this );
			return p;
		}
		if( state == null || !f_message.accept( p ) || !f_to.accept( p ) ) return p;
		xmpp.ChatStateExtension.set( untyped p, state );
		return p;
	}
	
	/**
		Force to send the current chat state in a standalone notification message.
	*/
	public function send( state : xmpp.ChatState ) : xmpp.Message {
		//TODO ? if( state == null ) state = xmpp.ChateState.active;
		if( chat == null )
			throw "No chat given, cannot set chat state";
		xmpp.ChatStateExtension.set( m, state );
		return chat.stream.sendPacket( m , false );
	}

}
