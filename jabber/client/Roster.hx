package jabber.client;

import jabber.core.PacketCollector;
import jabber.core.PresenceManager;
import xmpp.IQType;
import xmpp.roster.Item;
import xmpp.roster.AskType;
import xmpp.roster.Subscription;


enum SubscriptionMode {
	/** Accepts all subscription and unsubscription requests. */
	acceptAll; //TODO? acceptAll( subscribe : Bool );
	/** Rejects all subscription requests. */
	rejectAll;
	/** Ask user how to proceed. */
	manual;
}


/**
	Jabber client roster.
*/
class Roster {

	public static var defaultSubscriptionMode = SubscriptionMode.acceptAll;
	
	public dynamic function onLoad( r : Roster ) : Void;
	public dynamic function onAdd( r : Roster, i : Array<Item> ) : Void;
	public dynamic function onRemove( r : Roster, i : Array<Item> ) : Void;
	public dynamic function onUpdate( r : Roster, i : Array<Item> ) : Void;
	public dynamic function onPresence( r : Roster, i : Item, p: xmpp.Presence ) : Void;
	public dynamic function onResourcePresence( r : Roster, resource : String, p: xmpp.Presence  ) : Void;
	public dynamic function onSubscribed( r : Roster, i : Item ) : Void;
	public dynamic function onUnsubscribed( r : Roster, i : Item ) : Void;
	public dynamic function onSubscriptionRequest( r : Roster, i : Item ) : Void;
	
	public var stream(default,null) : Stream;
	public var available(default,null) : Bool;
	public var subscriptionMode : SubscriptionMode;
	public var items(default,null) : Array<Item>;
	public var groups(getGroups,null) : Array<String>;
	public var presence(default,null) : PresenceManager;
	public var resources(default,null) : Hash<xmpp.Presence>;
	
	var presenceMap : Hash<xmpp.Presence>;
	

	public function new( stream : Stream, ?subscriptionMode : SubscriptionMode ) {
		
		this.stream = stream;
		this.subscriptionMode = subscriptionMode != null ? subscriptionMode : defaultSubscriptionMode;
		
		available = false;
		items = new Array();
		presence = new PresenceManager( stream );
		resources = new Hash();
		presenceMap = new Hash();
		
		stream.collectors.add( new PacketCollector( [cast new xmpp.filter.PacketTypeFilter( xmpp.PacketType.presence )], handleRosterPresence, true ) );
		stream.collectors.add( new PacketCollector( [cast new xmpp.filter.IQFilter( xmpp.Roster.XMLNS )], handleRosterIQ, true ) );	
	}
	
	
	function getGroups() : Array<String> {
		var r = new Array<String>(); 
		for( item in items ) {
			for( g in item.groups ) {
				var has = false;
				for( a in r ) { if( a == g ) has = true; break; }
				if( !has ) r.push( g );
			}
		}
		return r;
	}
	
	
	public function getItem( jid : String ) : Item {
		for( i in items ) { if( i.jid == jid ) return i; }
		return null;
	}
	
	public function load() {
		var iq = new xmpp.IQ();
		iq.ext = new xmpp.Roster();
		stream.sendIQ( iq );
	}
	
	public function addItem( jid : String ) : Bool {
		if( !available ) return false;
		if( getItem( jid ) != null ) return false;
		requestItemAdd( jid );
		return true;
	}
	
	public function removeItem( jid : String ) : Bool {
		if( !available ) return false;
		var i = getItem( jid );
		if( i == null ) return false;
		var iq = new xmpp.IQ( IQType.set );
		iq.ext = new xmpp.Roster( [new xmpp.roster.Item( jid, Subscription.remove )] );
		var me = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
				case result :
					me.items.remove( i );
					me.onRemove( me, [i] );
				case error :
					//TODO
				default : //#
			}
		} );
		return true;
	}
	
	public function updateItem( item : Item ) : Bool {
		if( !available ) return false;
		if( getItem( item.jid ) == null ) return false;
		var iq = new xmpp.IQ( IQType.set );
		iq.ext = new xmpp.Roster( [item] );
		var me = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
				case result :
					me.onUpdate( me, [item] );
				case error :
					//TODO
				default : //#
			}
		} );
		return true;
	}
	
	public function subscribe( jid : String ) : Bool {
		if( !available ) return false;
		var i = getItem( jid );
		if( i == null ) {
			var iq = new xmpp.IQ( IQType.set );
			iq.ext = new xmpp.Roster( [new xmpp.roster.Item( jid )] );
			var me = this;
			stream.sendIQ( iq, function(r) {
				switch( r.type ) {
					case result :
						/*
						trace("TODO");
						TODO check if the item already got added (with iq.set frm server )
						to the roster, if not -> abort.
						if( me.getItem( jid ) == null ) {
							trace("?????????? result but not added to roster. ????");
						}
						*/
						
					case error :
						//TODO
					default : //#
				}
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
	
	public function confirmSubscription( jid : String, allow : Bool = true ) {
		//if( !available || getItem( jid ) == null ) return;
		var p = new xmpp.Presence( ( allow ) ? xmpp.PresenceType.subscribed : xmpp.PresenceType.unsubscribed );
		p.to = jid;
		stream.sendPacket( p );
	}
	
	public inline function hasItem( jid : String ) : Bool {
		return getItem( jid ) != null;
	}
	
	public function getPresence( jid : String ) : xmpp.Presence {
		return presenceMap.get( jid );
	}
	
	
	function handleRosterPresence( p : xmpp.Presence ) {
//		trace("händleRosterPresence");
		//if( !available ) return;
		
		var from = jabber.util.JIDUtil.parseBar( p.from );
		var resource = jabber.util.JIDUtil.parseResource( p.from );
		
		if( from == stream.jid.bare ) { // handle account resource presence
			if( resource == null ) return;
			resources.set( resource, p );
			onResourcePresence( this, resource, p );
			
		} else {
			var i = getItem( from );
			if( p.type != null ) {
				switch( p.type ) {
					case subscribe :
						switch( subscriptionMode ) {
							case acceptAll :
								confirmSubscription( p.from, true );
								//TODO subscribe to ?
							case rejectAll :
								var r = new xmpp.Presence( xmpp.PresenceType.unsubscribed );
								r.to = p.from;
								stream.sendPacket( r );
							case manual :
								onSubscriptionRequest( this, new xmpp.roster.Item( p.from ) );
						}
						return;
					
					case subscribed :
					//?	onSubscribed( this, i );
					//?	return;
					
					case unsubscribed :
						onUnsubscribed( this, i );
						return;
						
					default :
						trace("???????????????? "+p.type );
				}
			}
			if( i != null ) {
				presenceMap.set( from, p );
				onPresence( this, i, p );
			}
		}
	}
	
	function handleRosterIQ( iq : xmpp.IQ ) {
//		trace("händleRosterIQ","debug");
		switch( iq.type ) {
			
			case result :
				var added = new Array<Item>();
				var removed = new Array<Item>();
				var loaded = xmpp.Roster.parse( iq.ext.toXml() );
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
					onLoad( this );
				}
				if( added.length > 0 ) onAdd( this, added );
				if( removed.length > 0 ) onRemove( this, removed );
			
			case set :
				var loaded = xmpp.Roster.parse( iq.ext.toXml() );
				for( i in loaded ) {
					var item = getItem( i.jid );
					if( item != null ) { // update item
						item = i;
						onUpdate( this, [item] );
					} else { // new item
						items.push( i );
						onAdd( this, [i] );
					}
				}
				
			case error : 
				trace("ERRRORRR");
				//TODO
				
			default : 
		}
	}
	
	function requestItemAdd( jid : String ) {
		var iq = new xmpp.IQ( IQType.set );
		iq.ext = new xmpp.Roster( [new xmpp.roster.Item( jid )] );
		var me = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
				case result :
					var item = new Item( jid );
					me.items.push( item );
					me.onAdd( me, [item] );
				case error :
					//TODO
				default : //#
			}
		} );
	}
	
}
