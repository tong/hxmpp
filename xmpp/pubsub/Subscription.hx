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
