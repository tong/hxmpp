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
package xmpp.roster;

/**
	Roster subscription states.
*/
enum Subscription {
	
	/** The user and subscriber have no interest in each other's presence.*/
	none;
	
	/** The user is interested in receiving presence updates from the subscriber. */
    to;
    
	/** The subscriber is interested in receiving presence updates from the user. */
	from;
	
	/** The user and subscriber have a mutual interest in each other's presence. */
	both;
	
	/** The user wishes to stop receiving presence updates from the subscriber. */
	remove;
	
}
