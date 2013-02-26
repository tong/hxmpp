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

class Subscription {
	
	public var jid : String;
	public var node : String;
	public var subid : String;
	public var subscription : SubscriptionState;
	//subscribe_options : Array<>; // xmpp.PubSub only !
	
	public function new( jid : String,
						 ?node : String,
						 ?subid : String,
						 ?subscription : SubscriptionState ) {
		this.jid = jid;
		this.node = node;
		this.subid = subid;
		this.subscription = subscription;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "subscription" );
		x.set( "jid", jid );
		if( node != null ) x.set( "node", node );
		if( subid != null ) x.set( "subid", subid );
		if( subscription != null ) x.set( "subscription", Type.enumConstructor( subscription ) );
		// subscribe_options...
		return x;
	}
	
	public static function parse( x : Xml ) : Subscription {
		var s = new Subscription( x.get( "jid" ) );
		if( x.exists( "node" ) ) s.node = x.get( "node" );
		if( x.exists( "subid" ) ) s.subid = x.get( "subid" );
		if( x.exists( "subscription" ) ) s.subscription =  Type.createEnum( SubscriptionState, x.get( "subscription" ) );
		// subscribe_options...
		return s;
	}
	
}
