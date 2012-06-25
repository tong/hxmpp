/*
 * Copyright (c) 2012, tong, disktree.net
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
package xmpp.pubsub;

/**
	<a href="http://xmpp.org/extensions/xep-0060.html#accessmodels">http://xmpp.org/extensions/xep-0060.html#accessmodels</a>
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
