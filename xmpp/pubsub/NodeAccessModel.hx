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
package xmpp.pubsub;

/**
	http://xmpp.org/extensions/xep-0060.html#accessmodels
*/
enum NodeAccessModel {
	
	/**
		Any entity may subscribe to the node (i.e., without the necessity for subscription approval)
		and any entity may retrieve items from the node (i.e., without being subscribed).
		This SHOULD be the default access model for generic pubsub services.
	*/
	open;
	
	/**
		Any entity with a subscription of type "from" or "both" may subscribe to the node and retrieve items from the node.
		This access model applies mainly to instant messaging systems.
	*/
	presence;
	
	/**
		Any entity in the specified roster group(s) may subscribe to the node and retrieve items from the node.
		This access model applies mainly to instant messaging systems.
	*/
	roster;
	
	/**
		The node owner must approve all subscription requests, and only subscribers may retrieve items from the node.
	*/
	authorize;
	
	/**
		An entity may subscribe or retrieve items only if on a whitelist managed by the node owner.
		The node owner MUST automatically be on the whitelist.
		In order to add entities to the whitelist,
		the node owner SHOULD use the protocol specified in the Manage Affiliated Entities section of this document,
		specifically by setting the affiliation to "member".
	*/
	whitelist;
	
}
