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

enum Reason {
	
	/**
		The party prefers to use an existing session with the peer rather than initiate a new session.
		The Jingle session ID of the alternative session SHOULD be provided as the XML character data of the <sid/> child.
	*/
	alternative_session;
	
	/** The party is busy and cannot accept a session. */
	busy;
	
	/** The initiator wishes to formally cancel the session initiation request. */
	cancel;
	
	/** The action is related to connectivity problems. */
	connectivity_error;
	
	/** The party wishes to formally decline the session. */
	decline;
	
	/** The session length has exceeded a pre-defined time limit (e.g., a meeting hosted at a conference service). */
	expired;
	
	/** The action is related to a non-specific application error. */
	general_error;
	
	/** The entity is going offline or is no longer available. */
	gone;
	
	/** The action is related to media processing problems. */
	media_error;
	
	/** The action is generated during the normal course of state management and does not reflect any error. */
	success;
	
	/** A request has not been answered so the sender is timing out the request. */
	timeout;
	
	/** The party supports none of the offered application types. */
	unsupported_applications;
	
	/** The party supports none of the offered transport methods. */
	unsupported_transports;
}
