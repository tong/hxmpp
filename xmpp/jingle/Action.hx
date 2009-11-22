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
package xmpp.jingle;

/**
	Actions related to management of the overall Jingle session.
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
	
	transport_accept;
	transport_reject;
	transport_replace;
	
}
