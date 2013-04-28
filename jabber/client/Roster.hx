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
package jabber.client;

import jabber.XMPPError;
import jabber.client.RosterSubscriptionMode;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.Presence;
import xmpp.PresenceType;
import xmpp.roster.Item;
import xmpp.roster.AskType;
import xmpp.roster.Subscription;

/**
	Client roster (serverside saved contact list)
*/
class Roster {

	public static var defaultSubscriptionMode = manual;
	
	/** Roster got loaded */
	public dynamic function onLoad() {}
	
	/** Item got added to the roster */
	public dynamic function onAdd( i : Item ) {}
	
	/** Item got removed from your roster */
	public dynamic function onRemove( i : Item ) {}
	
	/** Item got updated */
	public dynamic function onUpdate( i : Item ) {}
	
	/** Subscribed to the presence of the contact */
	public dynamic function onSubscribed( i : Item ) {}
	
	/** Unsubscribed presence of the contact */
	public dynamic function onUnsubscribed( i : Item ) {}
	
	/** Incoming presence subscription request */
	public dynamic function onAsk( i : Item  ) {}
	
	/** Contact subscribed to your presence */
	public dynamic function onSubscription( jid : String  ) {}
	
	/** Contact unsubscribed from your presence */
	public dynamic function onUnsubscription( i : Item ) {}
	
	/** A roster manipulation error occured */
	public dynamic function onError( e : XMPPError ) {}
	
	public var stream(default,null) : Stream;
	public var subscriptionMode : RosterSubscriptionMode;
	public var available(default,null) : Bool;
	public var items(default,null) : Array<Item>;
	public var groups(get_groups,null) : Array<String>;
	
	var c_presence : PacketCollector;
	var c_message : PacketCollector;

	public function new( stream : Stream, ?subscriptionMode : RosterSubscriptionMode ) {
		
		this.stream = stream;
		this.subscriptionMode = ( subscriptionMode != null ) ? subscriptionMode : defaultSubscriptionMode;
		
		available = false;
		items = new Array();
		c_presence = stream.collect( [new xmpp.filter.PacketTypeFilter( xmpp.PacketType.presence )], handlePresence, true );
		c_message = stream.collect( [new xmpp.filter.IQFilter( xmpp.Roster.XMLNS )], handleIQ, true );
	}
	
	function get_groups() : Array<String> {
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
	
	/**
	*/
	public function dispose() {
		stream.removeCollector( c_presence );
		stream.removeCollector( c_message );
		available = false;
		items = new Array();
	}
	
	/**
	*/
	public function getItem( jid : String ) : Item {
		for( i in items ) { if( i.jid == jid ) return i; }
		return null;
	}
	
	/**
	*/
	public inline function hasItem( jid : String ) : Bool {
		return getItem( jabber.JIDUtil.bare( jid ) ) != null;
	}
	
	/**
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
		Remove entry from remote roster
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
		var _jid = JIDUtil.bare( jid );
		onSubscription( _jid );
		if( allow && subscribe ) {
			this.subscribe( _jid );
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
		if( groups != null )
			for( g in groups )
				i.groups.push( g );
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
			#if jabber_debug trace( "unhandled roster iq" ); #end
		}
	}
	
	function handlePresence( p : Presence ) {
		var jid = new jabber.JID( p.from );
		var i = getItem( jid.bare );
		if( p.type != null ) {
			switch( p.type ) {
			case subscribe :
				switch( subscriptionMode ) {
				case acceptAll(s) :
					confirmSubscription( p.from, true, s );
				case rejectAll :
					sendPresence( p.from, PresenceType.unsubscribed );
				case manual :
					onAsk( new Item( p.from ) );
				}
			case subscribed :
				onSubscribed( i );
			case unsubscribe :
				onUnsubscribed( i );
			case unsubscribed :
				items.remove( i );
				onUnsubscribed( i );
			default : //
				//trace( "TODO ????????????? "+p.type );
			}
		}
	}
}
