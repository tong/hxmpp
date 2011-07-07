/*
 *	This file is part of HXMPP.
 *	Copyright (c)2010 http://www.disktree.net
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
package jabber.client;

import jabber.XMPPError;
import jabber.stream.PacketCollector;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.Presence;
import xmpp.PresenceType;
import xmpp.roster.Item;
import xmpp.roster.AskType;
import xmpp.roster.Subscription;

/**
	Configuration how to handle incoming presence subscription requests
*/
enum RosterSubscriptionMode {
	/** Reject all subscription requests. */
	rejectAll;
	/** Ask how to proceed. */
	manual;
	//manual(cb:RosterItem->Bool);
	/** Accept all subscription and unsubscription requests. */
	acceptAll( subscribe : Bool );
}

/**
	Client roster (serverside saved contact list)
*/
class Roster {

	public static var defaultSubscriptionMode = manual;
	
	/** Roster got loaded */
	public dynamic function onLoad() : Void;
	/** Item got added to the roster */
	public dynamic function onAdd( i : Item ) : Void;
	/** Item got removed from your roster */
	public dynamic function onRemove( i : Item ) : Void;
	/** Item got updated */
	public dynamic function onUpdate( i : Item ) : Void;
	/** Subscribed to the presence of the contact */
	public dynamic function onSubscribed( i : Item ) : Void;
	/** Unsubscribed presence of the contact */
	public dynamic function onUnsubscribed( i : Item ) : Void;
	/** Incoming presence subscription request */
	public dynamic function onAsk( i : Item  ) : Void;
	/** Contact subscribed to your presence */
	public dynamic function onSubscription( jid : String  ) : Void;
	/** Contact unsubscribed from your presence */
	public dynamic function onUnsubscription( i : Item ) : Void;
	/** A roster manipulation error occured */
	public dynamic function onError( e : XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	public var subscriptionMode : RosterSubscriptionMode;
	public var available(default,null) : Bool;
	public var items(default,null) : Array<Item>;
	public var groups(getGroups,null) : Array<String>;
	
	var c_presence : PacketCollector;
	var c_message : PacketCollector;

	public function new( stream : Stream, ?subscriptionMode : RosterSubscriptionMode ) {
		this.stream = stream;
		this.subscriptionMode = subscriptionMode != null ? subscriptionMode : defaultSubscriptionMode;
		available = false;
		items = new Array();
		c_presence = stream.collect( [cast new xmpp.filter.PacketTypeFilter( xmpp.PacketType.presence )], handlePresence, true );
		c_message = stream.collect( [cast new xmpp.filter.IQFilter( xmpp.Roster.XMLNS )], handleIQ, true );
	}
	
	function getGroups() : Array<String> {
		var r = new Array<String>();
		for( i in items ) {
			for( g in i.groups ) {
				var has = false;
				for( a in r ) {
					if( a == g ) {
						has = true;
						break;
					}
				}
				if( !has ) r.push( g );
			}
		}
		return r;
	}
	
	public function dispose() {
		stream.removeCollector( c_presence );
		stream.removeCollector( c_message );
		available = false;
		items = new Array();
	}
	
	public function getItem( jid : String ) : Item {
		for( i in items ) { if( i.jid == jid ) return i; }
		return null;
	}
	
	public function hasItem( jid : String ) : Bool {
		return ( getItem( jabber.JIDUtil.parseBare( jid ) ) != null );
	}
	
	/*
	public function load() {
		var iq = new IQ();
		iq.x = new xmpp.Roster();
		stream.sendIQ( iq );
	}
	*/
	public function load() {
		var iq = new IQ();
		iq.x = new xmpp.Roster();
		var me = this;
		stream.sendIQ( iq, function(r:IQ) {
			me.available = true;
			me.items = Lambda.array( xmpp.Roster.parse( r.x.toXml() ) );
			me.onLoad();
		});
	}
	
	/**
		Add entry to your roster
	*/
	public function addItem( jid : String, ?groups : Iterable<String> ) : Bool {
		if( hasItem( jid ) )
			return false;
		sendAddItemRequest( jid, groups );
		return true;
	}
	
	/**
		Remove entry from your roster
	*/
	public function removeItem( jid : String ) : Bool {
		var i = getItem( jid );
		if( i == null )
			return false;
		var iq = new xmpp.IQ( IQType.set );
		iq.x = new xmpp.Roster( [new Item( jid, Subscription.remove )] );
		var me = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
			case result :
				me.items.remove( i );
				me.onRemove( i );
			case error :
				me.onError( new jabber.XMPPError( r ) );
			default : //
			}
		} );
		return true;
	}
	
	/**
		Subscribe to the presence of the entity.
		You will get presence updates from this entity (if confirmed).
	*/
	public function subscribe( jid : String ) : Bool {
		var i = getItem( jid );
		if( i == null ) {
			var iq = new xmpp.IQ( IQType.set );
			iq.x = new xmpp.Roster( [new Item( jid )] );
			var me = this;
			stream.sendIQ( iq, function(r) {
				switch( r.type ) {
				case result :
					me.sendPresence( jid, PresenceType.subscribe );
				case error :
					me.onError( new XMPPError( r ) );
				default : //
				}
			});
		} else {
			if( i.askType != AskType.subscribe ) {
				sendPresence( jid, PresenceType.subscribe );
			}
		}
		return true;
	}
	
	/**
		Unsubscribe from entities presence.
		The entity will no longer recieve presence updates.
	*/
	public function unsubscribe( jid : String, cancelSubscription : Bool = true ) : Bool {
		var i = getItem( jid );
		if( i == null )
			return false;
		if( i.askType != AskType.unsubscribe ) {
			sendPresence( jid, PresenceType.unsubscribe );
		}
		if( cancelSubscription )
			this.cancelSubscription( jid );
		return true;
	}
	
	/**
		Cancel the subscription from entity.
		You will no longer recieve presence updates.
	*/
	public function cancelSubscription( jid : String ) : Bool {
		sendPresence( jid, PresenceType.unsubscribe );
		return true;
	}
	
	/**
		Allow the requesting entity to recieve presence updates from you.
	*/
	public function confirmSubscription( jid : String, allow : Bool = true,
										 subscribe : Bool = false ) {
		sendPresence( jid, ( allow ) ? PresenceType.subscribed : PresenceType.unsubscribed );
		jid = JIDUtil.parseBare( jid );
		onSubscription( jid );
		if( subscribe ) {
			this.subscribe( jid );
		}
	}
	
	function sendPresence( jid : String, type : PresenceType ) {
		var p = new xmpp.Presence( type );
		p.to = jid;
		stream.sendPacket( p );
	}
	
	function sendAddItemRequest( jid : String, ?groups : Iterable<String> ) {
		var iq = new xmpp.IQ( IQType.set );
		var i = new Item( jid );
		if( groups != null ) for( g in groups ) i.groups.push( g );
		iq.x = new xmpp.Roster( [i] );
		var me = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
			case result :
				if( me.hasItem( jid ) )
					return; 
				var item = new Item( jid );
				me.items.push( item );
				me.onAdd( item );
			case error :
				me.onError( new XMPPError( r ) );
			default : //
			}
		} );
	}
	
	function handleIQ( iq : IQ ) {
		var loaded = xmpp.Roster.parse( iq.x.toXml() );
		switch( iq.type ) {
		case result :
			var added = new Array<Item>();
			var removed = new Array<Item>();
			for( i in loaded ) {
				var item = getItem( i.jid );
				if( i.subscription == Subscription.remove ) {
					items.remove( item );
					removed.push( item );
				} else {
					if( item == null ) { // new roster item
						item = i;
						items.push( item );
						added.push( item );
					}
				}
			}
			if( !available ) {
				available = true;
				onLoad();
			} else {
				if( added.length > 0 )
					for( i in added ) onAdd( i );
				if( removed.length > 0 )
					for( i in removed ) onRemove( i );
			}
		case set :
			for( i in loaded ) {
				var item = getItem( i.jid );
				if( item != null ) { // update item
					item = i;
					onUpdate( item );
				} else { // new item
					items.push( i );
					onAdd( i );
				}
			}
		case error :
			onError( new XMPPError( iq ) );
		default :
			#if JABBER_DEBUG trace( "Unhandled roster IQ" ); #end
		}
	}
	
	function handlePresence( p : Presence ) {
		var jid = new jabber.JID( p.from );
		var i = getItem( jid.bare );
		if( p.type != null ) {
			switch( p.type ) {
			case PresenceType.subscribe :
				switch( subscriptionMode ) {
				case acceptAll(s) :
					confirmSubscription( p.from, true, s );
				case rejectAll :
					sendPresence( p.from, xmpp.PresenceType.unsubscribed );
				case manual :
					onAsk( new Item( p.from ) );
				}
			case PresenceType.subscribed :
				onSubscribed( i );
			case PresenceType.unsubscribe :
				onUnsubscribed( i );
			case PresenceType.unsubscribed :
				items.remove( i );
				onUnsubscribed( i );
			default : //
				//trace("?????????????");
			}
		}
	}
}
