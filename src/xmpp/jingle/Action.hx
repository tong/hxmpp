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
package xmpp.jingle;

/**
	Actions related to management of a jingle session.
*/
enum Action {
	
	/** Accept a content-add or content-modify action received from another party. */
	content_accept;
	
	/**
		Add one or more new content types to the session.
	*/
	content_add;
	
	/**
		Change an existing content type.
	*/
	content_modify;
	
	/**
	*/
	content_reject;
	
	/**
		Remove one or more content types from the session.
	*/
	content_remove;
	
	/**
	*/
	description_info;
	
	/**
	*/
	security_info;
	
	/**
		Definitively accept a session negotiation (implicitly this action also serves as a content-accept).
	*/
	session_accept;
	
	/**
		 Send session-level information / messages, such as (for Jingle audio) a ringing message.
	*/
	session_info;
	
	/**
		Request negotiation of a new Jingle session.
	*/
	session_initiate;
	
	/**
		 End an existing session.
	*/
	session_terminate;
	
	/**
		Exchange transport candidates, it is mainly used in XEP-0176 but may be used in other transport specifications.
	*/
	transport_info;
	
	/**
		Accept a transport-replace action received from another party.
	*/
	transport_accept;
	
	/**
		Reject a transport-replace action received from another party.
	*/
	transport_reject;
	
	/**
		Redefine a transport method.
	*/
	transport_replace;
	
}
