package jabber.client;

import event.Dispatcher;
import jabber.core.PacketCollector;
import jabber.roster.SubscriptionMode;
import jabber.util.JIDUtil;
import xmpp.PacketType;
import xmpp.Presence;
import xmpp.IQ;
import xmpp.filter.IQFilter;
import xmpp.filter.PacketTypeFilter;
import xmpp.iq.Roster;



/**
*/
class RosterEntry extends jabber.roster.RosterEntry {
	public var roster : Roster;
	public function new() { super(); }
}


/**
	Jabber client roster.
*/
class Roster {
	
	public static var DEFAULT_SUBSCRIPTIONMODE = SubscriptionMode.acceptAll;
	
	public var onAvailable(default,null) : Dispatcher<Roster>;
	public var onAdd(default,null) 		 : Dispatcher<List<RosterEntry>>;
	public var onUpdate(default,null) 	 : Dispatcher<List<RosterEntry>>;
	public var onRemove(default,null) 	 : Dispatcher<List<RosterEntry>>;
	public var onPresence(default,null)  : Dispatcher<RosterEntry>;
	
	public var available(default,null) : Bool;
	public var presence(default,null) : Presence;
	public var entries(default,null) : List<RosterEntry>;
	public var unfiledEntries(getUnfiledEntries,null): List<RosterEntry>; // entries without group(s)
	public var groups(getGroups,null) : List<String>; 
	public var subscriptionMode : SubscriptionMode;
	public var stream(default,null) : Stream;


	public function new( stream : Stream ) {
		
		this.stream = stream;
		this.subscriptionMode = if( subscriptionMode == null ) DEFAULT_SUBSCRIPTIONMODE else subscriptionMode;
		
		available = false;
		presence = new Presence( "unavailable" );
		entries = new List();
		
		onAvailable = new Dispatcher();
		onAdd = new Dispatcher();
		onUpdate = new Dispatcher();
		onRemove = new Dispatcher();
		onPresence = new Dispatcher();
		
		// collect presence packets
		stream.collectors.add( new PacketCollector( [new PacketTypeFilter( PacketType.presence )], handlePresence, true ) );
		
		// collect roster iq packets
		//stream.collectors.add( new PacketCollector( [new IQFilter( xmpp.iq.Roster.XMLNS )], handleRosterIQ, true ) );
	}
	
		
	function getGroups() : List<String> {
		var groups = new List<String>();
		for( entry in entries ) 
			for( group in entry.groups ) 
				for( g in groups ) 
					if( group != g ) groups.add( group );
		return groups;
	}
	
	function getUnfiledEntries() : List<RosterEntry> {
		return entries.filter( function( e : RosterEntry ) { return e.groups.length == 0; } );
	}
	
		
	/**
		Requests roster load.
	*/
	public function load() {
		var iq = new IQ();
		iq.extension = new xmpp.iq.Roster();
		stream.sendIQ( iq, handleRosterIQ );
	}
	
	/**
		Returns the entry with the given JID.
	*/
	public function getEntry( jid : String ) : RosterEntry {
		if( !available ) return null;
		jid = JIDUtil.parseBarAddress( jid );
		for( entry in entries ) if( entry.jid == jid ) return entry;
		return null;
	}

	/**
		Requests to subscribe to the given entities roster.
	*/
	public function subscribe( to : String ) {
		
		// send roster iq to server.
		var items = new xmpp.iq.Roster();
		items.add( new RosterItem( to ) );
		var iq = new IQ( IQType.set );
		iq.extension = items;
		stream.sendIQ( iq, handleRosterIQ );
		
		// send subsbscribe presence to entity.
		var p = new Presence( "subscribe" );
		p.to = to;
		stream.sendPacket( p );
	}
	
	/**
		Requests to unsubscribe from the given entities roster.
	*/
	public function unsubscribe( from : String ) {
		//TODO test
		var iq = new IQ( IQType.set );
		iq.extension = new xmpp.iq.Roster( [new RosterItem( from, Subscription.remove )] );
		stream.sendIQ( iq, handleRosterIQ );
	}
	
	/**
		Sends given presence to all subscribed entries in the roster.
	*/
	public function sendPresence( p : Presence ) : Presence {
		if( !available ) return presence;
		presence = p;
		stream.sendPacket( presence );
		return presence;
	}
	
	/**
		Sets presence of all roster contacts to offline.
	*/
	public function setPresencesOffline() {
		for( entry in entries ) {
			entry.presence.type = "offline";//Presence.OFFLINE;
			onPresence.dispatchEvent( entry );
		}
	}
	
	/**
		Returns the [xmpp.Presence] of the given user.
	*/
	public function getPresence( jid : String ) : Presence {
		if( !available ) return null;
		var entry = getEntry( jid );
		if( entry != null ) return entry.presence;
		return null;
	}
	
	/**
		Returns the presence of the given jid at a specified resource.
	*/
	public function getResourcePresence( jid : String, resource : String ) {
		//TODO
	}
	
	/**
	*/
	public function getEntriesWithPresence( type : String ) : List<RosterEntry> {
		var list = new List<RosterEntry>();
		for( entry in entries ) {
			if( entry.presence.type == type ) list.add( entry );
		}
		return list;
	}
	
	/**
		Handles incoming xmpp.IQ (roster) packets.
	*/
	public function handleRosterIQ( iq : xmpp.IQ ) {
		
		switch( iq.type ) {
			
			case result :
			
				var added   = new List<RosterEntry>();
				var updated = new List<RosterEntry>();
				var removed = new List<RosterEntry>();
				
				for( item_xml in iq.extension.toXml().elements() ) {
					
					var entry = createRosterEntry( item_xml );
					
					if( entry.subscription == Subscription.remove ) { // remove entry
						var e = getEntry( entry.jid );
						if( e != null ) {
							entries.remove( e );
							removed.add( e );
						}
						
					} else { // add/update entry
						var existing = getEntry( entry.jid );
						if( existing == null ) { // add new entry
							entries.add( entry );
							added.add( entry );
							
						} else { // update existing entry
							existing = entry;
							updated.add( entry );
						}
					}
				}
				
				if( !available ) {
					available = true;
					#if JABBER_DEBUG trace( "Roster loaded.\n" ); #end
					onAvailable.dispatchEvent( this );
				}
				if( added.length > 0 )   onAdd.dispatchEvent( added );
				if( updated.length > 0 ) onUpdate.dispatchEvent( updated );
				if( removed.length > 0 ) onRemove.dispatchEvent( removed );
			
			default :
				// TODO
			
		}
	}
	
	/**
		Handles incoming xmpp.Presence packets.
	*/
	public function handlePresence( presence : xmpp.Presence ) {
		
		if( !available ) return;
		
		var from = JIDUtil.parseBarAddress( presence.from );
		var entry = getEntry( from );
		if( entry != null ) { // process only from entities in the roster
			entry.presence = presence;
			onPresence.dispatchEvent( entry );
			
		} else {
			//...
			trace("###########");
			if( presence.type == "subscribe" ) {
				if( subscriptionMode == SubscriptionMode.acceptAll ) {
					var p = new Presence( "subscribed" );
					p.to = presence.from;
					stream.sendPacket( p ); // allow subsription
					subscribe( presence.from ); // subscribe too, automaticly
				}
			}
		}
	}
	
	/**
		Creates a RosterEntry from given roster item xml.
	*/
	function createRosterEntry( xml : Xml ) : RosterEntry {
		var jid_str = xml.get( "jid" );
		var jid = JIDUtil.parseBarAddress( jid_str );
		var resource = JIDUtil.parseResource( jid_str );
		var subscription = RosterItem.getSubscriptionType( xml.get( "subscription" ) );
		var askType = RosterItem.getAskType( xml.get( "ask" ) );
		var groups = new List<String>();
		for( group in xml.elementsNamed( "group" ) ) groups.add( group.firstChild().nodeValue );
		var re = new RosterEntry();
		re.jid = jid;
		re.subscription = subscription;
		re.name =  xml.get( "name" );
		re.presence = null;
		re.askType = askType;
		re.groups = groups;
		re.groups = groups;
		re.roster = this;
		return re;
	}
	
}
