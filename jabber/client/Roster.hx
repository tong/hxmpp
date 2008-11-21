package jabber.client;

import jabber.core.PacketCollector;
import jabber.core.PresenceManager;
import jabber.event.XMPPErrorEvent;
import jabber.util.JIDUtil;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.Presence;
import xmpp.PresenceType;
import xmpp.filter.IQFilter;
import xmpp.filter.PacketTypeFilter;
import xmpp.roster.AskType;
import xmpp.roster.Subscription;


enum SubscriptionMode {
	
	/** Accepts all subscription and unsubscription requests. */
	acceptAll; //acceptAll( subscribe : Bool );
	
	/** Rejects all subscription requests. */
	rejectAll;
	
	/** Ask user how to proceed. */
	manual;
}


/**
	Entry in clients roster.
*/
class RosterEntry extends xmpp.roster.Item {
	
	/** Reference to this entries roster. */
	public var roster : Roster;
	/** */
	public var presence : Presence; // TODO var presence : Hash<xmpp.Presence>;
	
	public function new( jid : String, ?r : Roster ) {
		super( jid );
		roster = r;
	}
}


private typedef PendingEntry = {
	var id : String;
	var jid : String;
}


/**
	Jabber client roster.
*/
class Roster {

	public static var defaultSubscriptionMode = SubscriptionMode.acceptAll;
	
	public dynamic function onLoad( r : Roster ) {}
	public dynamic function onAdd( e : Array<RosterEntry> ) {}
	public dynamic function onRemove( e : Array<RosterEntry> ) {}
	public dynamic function onUpdate( e : Array<RosterEntry> ) {}
	public dynamic function onPresence( e : RosterEntry ) {}
	public dynamic function onResourcePresence( e : RosterEntry ) {}
	public dynamic function onSubscription( e : RosterEntry ) {}
	
	public var stream(default,null) : Stream;
	/** */
	public var available(default,null) : Bool;
	/** */
	public var presence(default,null) : PresenceManager;
	/** */
	public var entries(default,null) : Array<RosterEntry>;
	/** */
	public var subscriptionMode : SubscriptionMode;
	/** All groups in the roster */
	public var groups(getGroups,null) : List<String>; 
	/** Other available resources for this account.*/
	public var resources(default,null) : Hash<Presence>;
	
	public var pending_add(default,null) : List<PendingEntry>;
	public var pending_rem(default,null) : List<PendingEntry>;
	public var pending_upd(default,null) : List<PendingEntry>;
	

	public function new( stream : Stream, ?subscriptionMode : SubscriptionMode ) {
		
		this.stream = stream;
		this.subscriptionMode = ( subscriptionMode != null ) ? subscriptionMode : defaultSubscriptionMode;
		
		available = false;
		entries = new Array();
		resources = new Hash();
		presence = new PresenceManager( stream );
		
		pending_add = new List();
		pending_rem = new List();
		pending_upd = new List();
		
		// collect all presence packets
		stream.collectors.add( new PacketCollector( [cast new PacketTypeFilter( xmpp.PacketType.presence )], handlePresence, true ) );
		// collect all roster iq packets
		stream.collectors.add( new PacketCollector( [cast new IQFilter( xmpp.Roster.XMLNS )], handleRosterIQ, true ) );
	}


	function getGroups() : List<String> {
		var r = new List<String>(); 
		for( entry in entries ) {
			for( group in entry.groups ) {
				var has = false;
				for( a in r ) { if( a == group ) has = true; break; }
				if( !has ) r.add( group );
			}
		}
		return r;
	}
	
	
	/**
		Returns the entry with the given jid.
	*/
	public function getEntry( jid : String ) : RosterEntry {
		jid = JIDUtil.parseBar( jid );
		for( e in entries ) {
			if( e.jid == jid ) return e;
		}
		return null;
	}

	/**
		Requests roster load.
	*/
	public function load() {
		var iq = new IQ();
		iq.ext = new xmpp.Roster();
		stream.sendIQ( iq );
	}
	
	/*
	public function cleanup() {
		available = false;
		//pending = new List();
	}
	*/
	
	/**
		Requests to save the item in the remote roster.
	*/
	public function addEntry( jid : String ) : Bool {
		if( !available ) return false;
		var e = getEntry( jid );
		if( e != null ) return false;
		return requestEntryAdd( jid );
	}
	
	/**
		Requests to remove the entry from the remote roster.
	*/
	public function removeEntry( jid : String ) : Bool {
		if( !available ) return false;
		var e = getEntry( jid );
		if( e == null ) return false;
		var iq = new IQ( IQType.set );
		iq.ext = new xmpp.Roster( [new xmpp.roster.Item( jid, Subscription.remove )] );
		stream.sendIQ( iq, handleRosterIQ );
		pending_rem.add( { jid : e.jid, id : iq.id } );
		return true;
	}
	
	/**
		Requests to update the entry in the remote roster.
				You can pass in a RosterEntry object since it extends xmpp.roster.Item.
	*/
	public function update( entry : xmpp.roster.Item ) : Bool {
		if( !available ) return false;
		if( getEntry( entry.jid ) == null ) return false;
		var iq = new IQ( IQType.set );
		iq.ext = new xmpp.Roster( [entry] );
		stream.sendIQ( iq, handleRosterIQ );
		pending_upd.add( { jid : entry.jid, id : iq.id } );
		return true;
	}
	
	/**
		Requests to subscribe to the given entities roster.
	*/
	public function subscribe( to : String ) : Bool {
		if( !available ) return false;
		var e = getEntry( to );
		if( e == null ) {
			requestEntryAdd( to );
		} else {
			if( e.presence != null && e.subscription == Subscription.both ) return false;
		}
		var p = new Presence( PresenceType.subscribe );
		p.to = to;
		stream.sendPacket( p );
		return true;
	}
	
	/**
		Requests to unsubscribe to the given entities roster.
	*/
	public function unsubscribe( from : String, ?remove : Bool = false ) : Bool {
		if( !available ) return false;
		var e = getEntry( from );
		if( e == null ) return false;
		if( e.askType != AskType.unsubscribe ) {
			var p = new xmpp.Presence( xmpp.PresenceType.unsubscribe );
			p.to = from;
			stream.sendPacket( p );
		}
		if( remove ) {
			removeEntry( from );
		}
		return true;
	}
	
	
	function handlePresence( p : Presence ) {
		
		if( !available ) return;
		
		var from = JIDUtil.parseBar( p.from );
		var resource = JIDUtil.parseResource( p.from );
		
		if( from == stream.jid.bare ) { // handle account resource presence
			resources.set( resource, p );
			var e = new RosterEntry( from, this );
			e.presence = p;
			onResourcePresence( e );
			
		} else {
			var e = getEntry( from );
			if( p.type != null ) {
				switch( p.type ) {
					case subscribe :
						switch( subscriptionMode ) {
							case acceptAll :
								var response = new xmpp.Presence( xmpp.PresenceType.subscribed );
								response.to = p.from;
								stream.sendPacket( response );
							case rejectAll :
								var response = new xmpp.Presence( xmpp.PresenceType.unsubscribed );
								response.to = p.from;
								stream.sendPacket( response );
								
							case manual :
								if( e == null ) {
									e = new RosterEntry( from, this );
								}
								onSubscription( e );
								return;
						}
					default :
						//.
				}
			}
			if( e != null ) {
				e.presence = p;
				onPresence( e );
			}
		}
	}
	
	function handleRosterIQ( iq : IQ ) {
		//trace("handleRosterIQ");
		switch( iq.type ) {
			
			case result :
				for( pending in pending_add ) {
					if( iq.id == pending.id ) {
						pending_add.remove( pending );
						if( stream.sendData( new IQ( xmpp.IQType.result, iq.id ).toString() ) ) {
							var e = new RosterEntry( iq.from, this );
							entries.push( e );
							onAdd( [e] );				
							return;
						} else {
							trace("ERROR");
							return;
						}
					}
				}
				for( pending in pending_rem ) {
					if( iq.id == pending.id ) {
						var e = getEntry( pending.jid );
						if( e == null ) {
							trace("ERROR##+"); return;
						}
						pending_rem.remove( pending );
						if( stream.sendData( new IQ( xmpp.IQType.result, iq.id ).toString() ) ) {
							entries.remove( e );
							onRemove( [e] );				
							return;
						}
					}
				}
				for( pending in pending_upd ) {
					if( iq.id == pending.id ) {
						var e = getEntry( pending.jid );
						if( e == null ) {
							trace("ERROR##+"); return;
						}
						pending_upd.remove( pending );
						if( stream.sendData( new IQ( xmpp.IQType.result, iq.id ).toString() ) ) {
							onUpdate( [e] );				
							return;
						}
					}
				}
				handleRosterChangePacket( iq );
				
			case set :
				var items = xmpp.Roster.parse( iq.ext.toXml() );
				for( item in items ) {
					var e = getEntry( item.jid );
					if( e != null ) {
						e = cast item;
						e.roster = this;
						onUpdate( [e] );
						stream.sendData( new IQ( xmpp.IQType.result, iq.id ).toString() );
						onUpdate( [e] );
					}
				}
				
			case get :
			case error :
				trace("ROSTER IQ ERROR ");
				//onError( new jabber.event.XMPPErrorEvent<Stream>( stream, iq) );
		}
	}
	
	function handleRosterChangePacket( iq : IQ ) {
		if( iq.ext == null ) return;
		var added = new Array<RosterEntry>();
		var updated = new Array<RosterEntry>();
		var removed = new Array<RosterEntry>();
		var items = xmpp.Roster.parse( iq.ext.toXml() );
		for( item in items ) {
			var e = getEntry( item.jid );
			if( item.subscription == Subscription.remove ) {
				if( e != null ) {
					entries.remove( e );
					removed.push( e );
				} else {
					trace( "request to remove entry which isnt in the client roster" );
				}
			} else {
				if( e == null ) { // new entry
					e = cast item;
					e.roster = this;
					entries.push( e );
					added.push( e );
				} else { // update
					e = cast item;
					e.roster = this;
					updated.push( e );
				}
			}
		}
		if( !available ) {
			available = true;
			onLoad( this );
			return;
		}
		if( added.length > 0 ) onAdd( added );
		if( updated.length > 0 ) onUpdate( updated );
		if( removed.length > 0 ) onRemove( removed );
		//return { added, updated, removed };
	}
	

	function requestEntryAdd( jid : String ) : Bool {
		var iq = new IQ( IQType.set );
		iq.ext = new xmpp.Roster( [new xmpp.roster.Item( jid )] );
		stream.sendIQ( iq, handleRosterIQ );
		pending_add.add( { id : iq.id, jid : jid } );
		return true;
	}
	
}
