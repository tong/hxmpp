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
package xmpp;

/**
	XEP-0085: Chat State Notifications: http://xmpp.org/extensions/xep-0085.html
*/
enum ChatState {
	
	/**
		User is actively participating in the chat session.
		User accepts an initial content message, sends a content message, gives focus to the chat interface,
		or is otherwise paying attention to the conversation.
	*/
	active;
	
	/**
		User is composing a message.
		User is interacting with a message input interface specific to this chat session
		(e.g., by typing in the input area of a chat window).
	*/
	composing;
	
	/**
		User had been composing but now has stopped.
		User was composing but has not interacted with the message input interface for a short period of time
		(e.g., 5 seconds).
	*/
	paused;
	
	/**
		User has not been actively participating in the chat session.
		User has not interacted with the chat interface for an intermediate period of time (e.g., 30 seconds).
	*/
	inactive;
	
	/**
		User has effectively ended their participation in the chat session.
		User has not interacted with the chat interface, system, or device for a relatively long period of time
		(e.g., 2 minutes), or has terminated the chat interface (e.g., by closing the chat window).
	*/
	gone;
	
}
