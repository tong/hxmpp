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
package xmpp.pubsub;

/**
*/
enum SubscriptionState {
	
	/**
		 The node MUST NOT send event notifications or payloads to the Entity.
	*/
	none;
	
	/**
		An entity has requested to subscribe to a node and the request has not yet been approved by a node owner.
		The node MUST NOT send event notifications or payloads to the entity while it is in this state.
	*/
	pending;
	
	/**
		An entity has subscribed but its subscription options have not yet been configured.
		The node MAY send event notifications or payloads to the entity while it is in this state.
		The service MAY timeout unconfigured subscriptions.
	*/
	unconfigured;
	
	/**
		An entity is subscribed to a node.
		The node MUST send all event notifications (and, if configured, payloads) to the entity while it is in this state
		(subject to subscriber configuration and content filtering).
	*/
	subscribed;
	
}
