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
package jabber.client;

import jabber.PresenceManager;
import jabber.stream.PacketCollector;
import xmpp.IQType;
import xmpp.roster.Item;
import xmpp.roster.AskType;
import xmpp.roster.Subscription;

enum RosterSubscriptionMode {
	/** Accept all subscription and unsubscription requests. */
	acceptAll( subscribe : Bool );
	/** Rejects all subscription requests. */
	rejectAll;
	/** Ask user how to proceed. */
	manual;
}

/**
	Jabber client roster.
*/
class Roster {
//TODO class Roster<RosterItem:xmpp.roster.Item>

	public static var defaultSubscriptionMode = RosterSubscriptionMode.manual;
	
	public dynamic function onLoad() : Void;
	public dynamic function onAdd( items : Array<Item> ) : Void;
	public dynamic function onRemove( items : Array<Item> ) : Void;
	public dynamic function onUpdate( items : Array<Item> ) : Void;
	public dynamic function onPresence( item : Item, p : xmpp.Presence ) : Void; //TODO remove (?)
	public dynamic function onResourcePresence( resource : String, p : xmpp.Presence  ) : Void;
	public dynamic function onSubscribed( item : Item ) : Void;
	public dynamic function onUnsubscribed( item : Item ) : Void;
	public dynamic function onSubscription( item : Item ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	public var available(default,null) : Bool;
	public var subscriptionMode : RosterSubscriptionMode;
	public var items(default,null) : Array<Item>;
	public var groups(getGroups,null) : Array<String>;
	public var presence(default,null) : PresenceManager;
	public var resources(default,null) : Hash<xmpp.Presence>;
	
	var presenceMap : Hash<xmpp.Presence>; // TODO remove ?

	public function new( stream : Stream, ?subscriptionMode : RosterSubscriptionMode ) {
		this.stream = stream;
		this.subscriptionMode = subscriptionMode != null ? subscriptionMode : defaultSubscriptionMode;
		available = false;
		items = new Array();
		presence = new PresenceManager( stream );
		resources = new Hash();
		presenceMap = new Hash();
		// collect presences and roster IQs
		stream.collect( [cast new xmpp.filter.PacketTypeFilter( xmpp.PacketType.presence )], handleRosterPresence, true );
		stream.collect( [cast new xmpp.filter.IQFilter( xmpp.Roster.XMLNS )], handleRosterIQ, true );	
	}
	
	function getGroups() : Array<String> {
		var r = new Array<String>(); 
		for( item in items ) {
			for( g in item.groups ) {
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
	
	public function getItem( jid : String ) : Item {
		for( i in items ) {
			if( i.jid == jid ) {
				return i;
			}
		}
		return null;
	}
	
	public function load() {
		var iq = new xmpp.IQ();
		iq.x = new xmpp.Roster();
		stream.sendIQ( iq );
	}
	
	public function addItem( jid : String ) : Bool {
		if( !available || hasItem( jid ) ) return false;
		requestItemAdd( jid );
		return true;
	}
	
	public function removeItem( jid : String ) : Bool {
		if( !available ) return false;
		var i = getItem( jid );
		if( i == null ) return false;
		var iq = new xmpp.IQ( IQType.set );
		iq.x = new xmpp.Roster( [new xmpp.roster.Item( jid, Subscription.remove )] );
		var _this = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
			case result :
				_this.items.remove( i );
				_this.onRemove( [i] );
			case error : _this.onError( new jabber.XMPPError( _this, r ) );
			default : //
			}
		} );
		return true;
	}
	
	public function updateItem( item : Item ) : Bool {
		if( !available || !hasItem( item.jid ) )
			return false;
		var iq = new xmpp.IQ( IQType.set );
		iq.x = new xmpp.Roster( [item] );
		var _this = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
			case result : _this.onUpdate( [item] );
			case error : _this.onError( new jabber.XMPPError( _this, r ) );
			default :
			}
		} );
		return true;
	}
	
	public function subscribe( jid : String ) : Bool {
		if( !available ) return false;
		var i = getItem( jid );
		if( i == null ) {
			var iq = new xmpp.IQ( IQType.set );
			iq.x = new xmpp.Roster( [new xmpp.roster.Item( jid )] );
			var me = this;
			stream.sendIQ( iq, function(r) {
					/*
				switch( r.type ) {
				case result :
					trace("TODO");
					TODO check if the item already got added (with iq.set frm server )
					to the roster, if not -> abort.
					if( me.getItem( jid ) == null ) {
						trace("?????????? result but not added to roster. ????");
					}
				case error :
					//TODO
				default : //#
				}
					*/
			} );
		} else if( i.subscription == Subscription.both ) {
			return false; // already subscribed
		}
		var p = new xmpp.Presence( xmpp.PresenceType.subscribe );
		p.to = jid;
		return stream.sendPacket( p ) != null;
	}
	
	public function unsubscribe( jid : String ) : Bool {
		if( !available ) return false;
		var i = getItem( jid );
		if( i == null ) return false;
		if( i.askType != AskType.unsubscribe ) {
			var p = new xmpp.Presence( xmpp.PresenceType.unsubscribe );
			p.to = jid;
			stream.sendPacket( p );
		}
		return true;
	}
	
	public function hasItem( jid : String ) : Bool {
		return ( getItem( jabber.JIDUtil.parseBare( jid ) ) != null );
	}
	
	public function getPresence( jid : String ) : xmpp.Presence {
		return presenceMap.get( jid );
	}
	
	//public
	function confirmSubscription( jid : String, allow : Bool = true ) {
		//if( !available || getItem( jid ) == null ) return;
		var p = new xmpp.Presence( ( allow ) ? xmpp.PresenceType.subscribed : xmpp.PresenceType.unsubscribed );
		p.to = jid;
		stream.sendData( p.toString() );
	}
	
	function handleRosterPresence( p : xmpp.Presence ) {
		//if( !available ) return;
		var from = jabber.JIDUtil.parseBare( p.from );
		var resource = jabber.JIDUtil.parseResource( p.from );
		if( from == stream.jid.bare ) { // handle account resource presence
			if( resource == null ) return;
			resources.set( resource, p );
			onResourcePresence( resource, p );
			return;
		}
		var i = getItem( from );
		if( p.type != null ) {
			switch( p.type ) {
			case subscribe :
				switch( subscriptionMode ) {
				case acceptAll(s) :
					confirmSubscription( p.from, true );
					if( s ) subscribe( p.from );
				case rejectAll :
					var r = new xmpp.Presence( xmpp.PresenceType.unsubscribed );
					r.to = p.from;
					stream.sendPacket( r );
				case manual :
					onSubscription( new xmpp.roster.Item( p.from ) );
				}
				return;
			case subscribed :
				onSubscribed( i );
			/*
			case unsubscribed :
				onUnsubscribed( i );
				return;
			*/
			case unsubscribe :
				onUnsubscribed( i );
				return;
			default :
			//	trace( "???? check "+p.type );
				//onPresence( i, p );
			}
		}
		if( i != null ) {
			presenceMap.set( from, p );
			onPresence( i, p );
		}
	}
	
	function handleRosterIQ( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			var added = new Array<Item>();
			var removed = new Array<Item>();
			var loaded = xmpp.Roster.parse( iq.x.toXml() );
			for( i in loaded ) {
				var item = getItem( i.jid );
				if( i.subscription == Subscription.remove ) {
					if( item != null ) {
						items.remove( item );
						removed.push( item );
					}
				} else {
					if( item == null ) { // new roster item
						item = i;
						items.push( item );
						added.push( item );
					} else { // update roster item
						trace("TODO UPDATE ROSTER ITEM");
					}
				}
			}
			if( !available ) {
				available = true;
				onLoad();
			}
			if( added.length > 0 ) onAdd( added );
			if( removed.length > 0 ) onRemove( removed );
		case set :
			// TODO check subscription
			var loaded = xmpp.Roster.parse( iq.x.toXml() );
			for( i in loaded ) {
				var item = getItem( i.jid );
				if( item != null ) { // update item
					item = i;
					onUpdate( [item] );
				} else { // new item
					items.push( i );
					onAdd( [i] );
				}
			}
		case error : 
			//TODO
			trace("ERROR");
		default : 
			trace("??? unhandled");
		}
	}
	
	function requestItemAdd( j : String ) {
		var iq = new xmpp.IQ( IQType.set );
		iq.x = new xmpp.Roster( [new xmpp.roster.Item( j )] );
		var me = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
			case result :
				var item = new Item( j );
				me.items.push( item );
				me.onAdd( [item] );
			case error :
				//TODO
			default : //#
			}
		} );
	}
	
}
