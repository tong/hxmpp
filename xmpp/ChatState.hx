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
package xmpp;

/**
	<a href="http://xmpp.org/extensions/xep-0085.html">XEP-0085: Chat State Notifications</a><br/>
*/
enum ChatState {
	
	/**
		User is actively participating in the chat session.<br/>
		User accepts an initial content message, sends a content message, gives focus to the chat interface,
		or is otherwise paying attention to the conversation.
	*/
	active;
	
	/**
		User is composing a message.<br/>
		User is interacting with a message input interface specific to this chat session
		(e.g., by typing in the input area of a chat window).
	*/
	composing;
	
	/**
		User had been composing but now has stopped.<br/>
		User was composing but has not interacted with the message input interface for a short period of time
		(e.g., 5 seconds).
	*/
	paused;
	
	/**
		User has not been actively participating in the chat session.<br/>
		User has not interacted with the chat interface for an intermediate period of time (e.g., 30 seconds).
	*/
	inactive;
	
	/**
		User has effectively ended their participation in the chat session.<br/>
		User has not interacted with the chat interface, system, or device for a relatively long period of time
		(e.g., 2 minutes), or has terminated the chat interface (e.g., by closing the chat window).
	*/
	gone;
	
}
