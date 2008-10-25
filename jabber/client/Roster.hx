package jabber.client;

import jabber.core.PacketCollector;
import jabber.util.JIDUtil;
import xmpp.PacketType;
import xmpp.Presence;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.Roster;
import xmpp.roster.AskType;
import xmpp.roster.Subscription;
import xmpp.filter.IQFilter;
import xmpp.filter.PacketTypeFilter;


//enum PresenceSubscriptionMode {
enum SubscriptionMode {
	
	/** Accepts all subscription and unsubscription requests. */
	acceptAll;
	//acceptAll( subscribe : Bool );
	
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
	public var presence : xmpp.Presence;
	// TODO var presence : Hash<xmpp.Presence>;
	
	public function new( jid : String, ?r : Roster ) {
		super( jid );
		roster = r;
	}
	
	/*
	public function setItemValue( item : xmpp.RosterItem ) {
		
	}
	*/
	
	/*
	#if JABBER_DEBUG
	
	public function info() : String {
		return "("+this.jid+")";
	}
	
	#end
	*/
}


/**
	Jabber client roster.
*/
class Roster {

	public static var DEFAULT_SUBSCRIPTIONMODE = SubscriptionMode.acceptAll;
	
	public dynamic function onAvailable( roster : Roster ) {}
	public dynamic function onAdd( entries : List<RosterEntry> ) {}
	public dynamic function onUpdate( entries : List<RosterEntry> ) {}
	public dynamic function onRemove( entries : List<RosterEntry> ) {}
	public dynamic function onPresence( entry : RosterEntry ) {}
	public dynamic function onResourcePresence( resource : String ) {}
	
	public var available(default,null) : Bool;
	public var presence(default,null) : jabber.core.PresenceManager;
	public var entries(default,null) : Array<RosterEntry>;
//	public var unfiledEntries(getUnfiledEntries,null): List<RosterEntry>; // entries without group(s)
	public var subscriptionMode : SubscriptionMode;
	public var groups(getGroups,null) : List<String>; 
	public var stream(default,null) : Stream;
	public var resources(default,null) : Hash<Presence>; // other available resources for this account.
	
	var pending_add : List<String>;
	var pending_remove : List<String>;
	

	public function new( stream : Stream, ?subscriptionMode : SubscriptionMode ) {
		
		this.stream = stream;
		this.subscriptionMode = ( subscriptionMode == null ) ? DEFAULT_SUBSCRIPTIONMODE : subscriptionMode;
		
		available = false;
		entries = new Array();
		presence = new jabber.core.PresenceManager( stream );
		resources = new Hash();
		
		pending_remove = new List();
		pending_add = new List();
		
		// collect presence packets
		stream.collectors.add( new PacketCollector( [cast new PacketTypeFilter( PacketType.presence )], handlePresence, true ) );
		// collect roster iq packets
		stream.collectors.add( new PacketCollector( [cast new IQFilter( xmpp.Roster.XMLNS )], handleRosterIQ, true ) );
	}
	
		
	function getGroups() : List<String> {
		var groups = new List<String>();
		for( entry in entries )
			for( group in entry.groups )
				for( g in groups )
					if( group != g ) groups.add( group );
		return groups;
	}
	
	/*
	function getUnfiledEntries() : List<RosterEntry> {
		return entries.filter( function( e : RosterEntry ) { return e.groups.length == 0; } );
	}
	*/
	

	/**
		Returns the entry with the given JID.
	*/
	public function getEntry( jid : String ) : RosterEntry {
		if( !available ) return null;
		jid = JIDUtil.parseBar( jid );
		for( e in entries ) if( e.jid == jid ) return e;
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
	
	/**
		Requests to save the item in the remote  roster.
	*/
	public function add( jid : String ) : Bool {
		if( !available ) return false;
		var entry = getEntry( jid );
		if( entry != null ) return false;
		var iq = new IQ( IQType.set );
		iq.ext = new xmpp.Roster( [new xmpp.roster.Item( jid )] );
		stream.sendIQ( iq, handleRosterIQ );
		pending_add.add( iq.id );
		return true;
	}
	
	/**
		Requests to remove the entry from the remote roster.
	*/
	public function remove( jid : String ) : Bool {
		if( !available ) return false;
		var entry = getEntry( jid );
		if( entry == null ) return false;
		var iq = new IQ( IQType.set );
		iq.ext = new xmpp.Roster( [new xmpp.roster.Item( jid, Subscription.remove )] );
		stream.sendIQ( iq, handleRosterIQ );
		pending_remove.add( iq.id );
		return true;
	}
	
	/**
		Requests to update the entry in the remote roster.
	*/
	public function update( entry : xmpp.roster.Item ) {
		if( !available ) return false;
		if( getEntry( entry.jid ) == null ) return false;
		//if( entry.roster != null || entry.roster != this ) return false;
		var iq = new IQ( IQType.set );
		iq.ext = new xmpp.Roster( [entry] );
		stream.sendIQ( iq, handleRosterIQ );
		pending_add.add( iq.id );
		return true;
	}
	
	/**
		Requests to subscribe to the given entities roster.
	*/
	public function subscribe( to : String ) : Bool {
		if( !available ) return false;
		var entry = getEntry( to );
		if( entry == null ) {
			var iq = new IQ( IQType.set );
			var ext = new xmpp.Roster();
			ext.add( new xmpp.roster.Item( to ) );
			iq.ext = ext;
			stream.sendIQ( iq, handleRosterIQ );
			pending_add.add( iq.id );
		}
		var p = new Presence( xmpp.PresenceType.subscribe );
		p.to = to;
		stream.sendPacket( p );
		return true;
	}
	
	/**
		Requests to unsubscribe from the roster entry.
	*/
	public function unsubscribe( from : String, ?remove : Bool ) : Bool {
		if( !available ) return false;
		if( getEntry( from ) == null ) return false;
		var p = new Presence( xmpp.PresenceType.unsubscribe );
		p.to = from;
		stream.sendPacket( p );
		//TODO remove
		return true;
	}
	
	/**
		Sets presence of all roster contacts to offline.
	*/
	public function setPresencesOffline() {
		for( entry in entries ) {
			entry.presence.type = xmpp.PresenceType.unavailable;
			onPresence( entry );
		}
	}
	
	/**
		Returns the presence of the given user.
	*/
	public function getPresence( jid : String ) : Presence {
		if( !available ) return null;
		var e = getEntry( jid );
		if( e != null ) return e.presence;
		return null;
	}
	
	/*
		TODO
		Returns the presence of the given jid at a specified resource.
	public function getResourcePresence( jid : String, resource : String ) : xmpp.Presence {
		if( !entries.exists( jid ) ) return null;
		var e = entries.get( jid );
		if( !e.presence.exists( resource ) ) return null;
		return e.presence.get( resource );
	}
	*/
	
	/**
	*/
	public function getEntriesWithPresence( type : xmpp.PresenceType ) : List<RosterEntry> {
		var list = new List<RosterEntry>();
		for( entry in entries ) {
			if( entry.presence.type == type ) list.add( entry );
		}
		return list;
	}
	
	/**
		Handles incoming xmpp.Presence packets.
	*/
	public function handlePresence( presence : xmpp.Presence ) {

		if( !available ) return;
		
		var from = JIDUtil.parseBar( presence.from );
	
		trace( "handlePresence "+from+" / "+presence.type );
		
		if( from == stream.jid.bare ) {
			// handlr account resource presence
			var resource = jabber.util.JIDUtil.parseResource( presence.from );
			resources.set( resource, presence );
			onResourcePresence( resource );
			return;
		}
			
		var entry = getEntry( from );
		
		
		if( presence.type != null ) {
			
			switch( presence.type ) {
				
				case subscribe :
					switch( subscriptionMode ) {
						
						case acceptAll : 
						trace("ACCEPT ALLLL " );
						
							var p = new Presence( xmpp.PresenceType.subscribed );
							p.to = presence.from;
							stream.sendPacket( p );
							
						//	if( entry.subscription == from ) {
						//	}
							
						case rejectAll :
						case manual :	
					}
					
				case subscribed :
					
				default :
			}
		} else {
			
		}
		
		/*
		if( entry != null ) {
			// handle presence from roster user
		//	entry.presence = presence;
		//	onPresence( entry );
			
			switch( presence.type ) {
				case subscribe :
					switch( subscriptionMode ) {
						case rejectAll :
						case acceptAll :
							trace("ACCEPT SUBSRIPTION REQUEST");	
						case manual :
					}
				
				case unsubscribe :	
				case unsubscribed :
				case unavailable :
				case subscribed :
				case probe :
				case error :
			}
			
			
		} else {
			// handle presence from new user
			switch(  presence.type ) {
				
				case xmpp.PresenceType.subscribe :
					trace(from+" wants to subscibe..");
					
					switch( subscriptionMode ) {
						
						case rejectAll :
							var p = new Presence( "unsubscribed" );
							p.to = presence.from;
							stream.sendPacket( p );
							return;
							
						case acceptAll :
							trace("ACCEPT ALL");
							var p = new Presence( "subscribed" );
							p.to = presence.from;
							stream.sendPacket( p );
							//subscribe( presence.from ); // subscribe too, automaticly
							//onPresence( entry );
							
						case manual :
							//onPresence( entry );
					}
				
				case xmpp.PresenceType.subscribed :
				trace("SUBScribED");
				
				case xmpp.PresenceType.unsubscribed :
					//TODO
					
				default :
					if( from == stream.jid.barAdress ) {
						// handler account resource presence
						var resource = jabber.util.JIDUtil.parseResource( presence.from );
						resources.set( resource, presence );
						onResourcePresence( resource );
					}
			}
			//...
		}
		*/
	}
	
	/**
		Handles incoming xmpp.IQ (roster) packets.
	*/
	public function handleRosterIQ( iq : xmpp.IQ ) {
		
		trace( "handleRosterIQ / "+iq.type );
		
		switch( iq.type ) {
			
			case result :
				for( pending in pending_add ) {
					trace("pending add: "+pending);
					if( iq.id == pending ) {
						pending_add.remove( pending );
						var result_iq = new xmpp.IQ( xmpp.IQType.result, iq.id );
						stream.sendData( result_iq.toString() );
						return;
					}
				}
				for( pending in pending_remove ) {
					trace("pending remove: "+pending);
					if( iq.id == pending ) {
						pending_remove.remove( pending );
						var result_iq = new xmpp.IQ( xmpp.IQType.result, iq.id );
						stream.sendData( result_iq.toString() );
						return;
					}
				}
				handleRosterChangePacket( iq );
				
			case set :
				var items = xmpp.Roster.parse( iq.ext.toXml() );
				for( item in items ) {
					// automatic subscription ???
					if( item.subscription == from && item.askType != AskType.subscribe ) {
						var p = new Presence( xmpp.PresenceType.subscribe );
						p.to = item.jid;
						stream.sendPacket( p );
					}
				}
				handleRosterChangePacket( iq );
				
			case error :
			case get :
		}
	}
	
	#if JABBER_DEBUG
	
	public function toString() : String {
		return "Roster("+stream.jid.bare+",available:"+available+",entries:"+entries.length+",subscriptionMode:"+subscriptionMode+")";
	}
	
	#end
	
	
	function handleRosterChangePacket( iq : xmpp.IQ ) {
		if( iq.ext == null ) return;
		var added = new List<RosterEntry>();
		var updated = new List<RosterEntry>();
		var removed = new List<RosterEntry>();
		var items = xmpp.Roster.parse( iq.ext.toXml() );
		for( item in items ) {
			
			if( item.subscription == Subscription.remove ) {
				// remove entry
				var entry = getEntry( item.jid );
				if( entry != null ) {
					entries.remove( entry );
					removed.add( entry );
				}
			} else {
				var entry = getEntry( item.jid );
				if( entry == null ) {
					// add new entry
					entry = cast item;
					entry.roster = this;
					entries.push( entry );
					added.add( entry );
				} else {
					//TODO entry.setItemData( item );
					entry = cast item;
					entry.roster = this;
					updated.add( entry );
				}
			}	
		}
		if( !available ) {
			available = true;
			onAvailable( this );
		}
		if( added.length > 0 ) onAdd( added );
		if( updated.length > 0 ) onUpdate( updated );
		if( removed.length > 0 ) onRemove( removed );
	}
	
}
