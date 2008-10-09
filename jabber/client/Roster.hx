package jabber.client;

import jabber.core.PacketCollector;
import jabber.roster.SubscriptionMode;
import jabber.util.JIDUtil;
import xmpp.PacketType;
import xmpp.Presence;
import xmpp.IQ;
import xmpp.filter.IQFilter;
import xmpp.filter.PacketTypeFilter;
import xmpp.IQRoster;

import jabber.event.RosterEvent;


/**
	Wrapper for handling users presence.
*/
private class PresenceManager {
	
	public var type(getType,setShow) : String;
	public var show(getShow,setShow) : String;
	public var status(getStatus,setShow) : String;
	public var priority(getPriority,setPriority) : Int;
	
	var r : Roster;
	var p : xmpp.Presence;
	
	public function new( roster : Roster ) {
		r = roster;
		p = new xmpp.Presence();
	}
	
	function getType() : String { return p.type; }
	function setType( v : String ) : String {
		if( v == p.type ) return v;
		p.type = v;
		r.stream.sendPacket( p );
		return v;
	}
	function getShow() : String { return p.show; }
	function setShow( v : String ) : String {
		if( v == p.show ) return v;
		p.show = v;
		r.stream.sendPacket( p );
		return v;
	}
	function getStatus() : String { return p.status; }
	function setStatus( v : String ) : String {
		if( v == p.status ) return v;
		p.status = v;
		r.stream.sendPacket( p );
		return v;
	}
	function getPriority() : Int { return p.priority; }
	function setPriority( v : Int ) : Int {
		if( v == p.priority ) return v;
		p.priority = v;
		r.stream.sendPacket( p );
		return v;
	}
	
	
	/**
	*/
	public function change( ?type : String, ?show : String, ?status : String, ?priority : Int ) {
		var changed = false;
		if( type != p.type ) { p.type = type; changed = true; }
		if( show != p.show ) { p.show = show; changed = true; }
		if( status != p.status ) { p.status = status; changed = true; }
		if( priority != p.priority ) { p.priority = priority; changed = true; }
		if( changed ) r.stream.sendPacket( p );
	}
	
}


/**
	Entry in clients roster.
*/
class RosterEntry extends jabber.roster.Entry {
	
	public var roster(default,null) : Roster;
	
	public function new( r : Roster ) {
		super();
		roster = r;
	}
	
}


/**
	Jabber client roster.
*/
class Roster {
	
	public static var DEFAULT_SUBSCRIPTIONMODE = SubscriptionMode.acceptAll;
	
	public var available(default,null) : Bool;
	public var presence(default,null) : PresenceManager;
	public var entries(default,null) : Array<RosterEntry>;
//	public var unfiledEntries(getUnfiledEntries,null): List<RosterEntry>; // entries without group(s)
	public var subscriptionMode : SubscriptionMode;
	public var groups(getGroups,null) : List<String>; 
	public var stream(default,null) : Stream;
	
	//var pending_subscriptions : List<RosterEntry>;
	//var pending_unsubscriptions : Hash<RosterEntry>;
	

	public function new( stream : Stream, ?subscriptionMode : jabber.roster.SubscriptionMode ) {
		
		this.stream = stream;
		this.subscriptionMode = ( subscriptionMode == null ) ? DEFAULT_SUBSCRIPTIONMODE : subscriptionMode;
		
		available = false;
		entries = new Array();
		presence = new PresenceManager( this );
		//pending_unsubscriptions = new Hash();
		
		// collect presence packets
		stream.collectors.add( new PacketCollector( [cast new PacketTypeFilter( PacketType.presence )], handlePresence, true ) );
		// collect roster iq packets
		//stream.collectors.add( new PacketCollector( [new IQFilter( xmpp.IQRoster.XMLNS )], handleRosterIQ, true ) );
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
	
	//public dynamic function change( e : jabber.event.RosterEvent<Roster,RosterEntry> ) : Void;
	public dynamic function onAvailable( roster : Roster ) {}
	public dynamic function onAdd( entries : List<RosterEntry> ) {}
	public dynamic function onUpdate( entries : List<RosterEntry> ) {}
	public dynamic function onRemove( entries : List<RosterEntry> ) {}
	public dynamic function onPresence( entry : RosterEntry ) {}

	/**
		Requests roster load.
	*/
	public function load() {
		var iq = new IQ();
		iq.ext = new xmpp.IQRoster();
		stream.sendIQ( iq, handleRosterIQ );
	}
	
	/**
		Returns the entry with the given JID.
	*/
	public function getEntry( jid : String ) : RosterEntry {
		if( !available ) return null;
		jid = JIDUtil.parseBar( jid );
		for( entry in entries ) if( entry.jid == jid ) return entry;
		return null;
	}
	
	/**
		Requests to remove the entry from the remote roster.
	*/
	public function remove( jid : String ) : Bool {
		var entry = getEntry( jid );
		if( entry == null ) return false;
		var iq = new IQ( IQType.set );
		iq.ext = new xmpp.IQRoster( [new RosterItem( jid, Subscription.remove )] );
		var me = this;
		stream.sendIQ( iq, function(iq) {
			switch( iq.type ) {
				case result :
					var rem = new List<RosterEntry>();
					rem.add( entry );
					me.onRemove( rem );
					
					
				default :
			}
		} );
		return true;
	}
	
	/**
		Requests to subscribe to the given entities roster.
	*/
	public function subscribe( to : String ) {
		var entry = getEntry( to );
		if( entry != null ) {
			if( entry.subscription != null || entry.subscription != from ) {
				return;
			} 
		}
		// send roster iq to server.  hmmmmm ????? remove
		var items = new xmpp.IQRoster();
		items.add( new RosterItem( to ) );
		var iq = new IQ( IQType.set );
		iq.ext = items;
		stream.sendIQ( iq, handleRosterIQ );
		// send subsbscribe presence to entity.
		var p = new Presence( "subscribe" );
		p.to = to;
		stream.sendPacket( p );
	}
	
	/**
		Requests to unsubscribe from the roster entry.
	*/
	public function unsubscribe( from : String ) : Bool {
		var p = new Presence( "unsubscribe" );
		p.to = from;
		stream.sendPacket( p );
		return true;
	}
	
	/**
		Sends given presence to all subscribed entries in the roster.
		//TODO presence(getPresence,setPresence)
	public function setPresence( p : Presence ) : Presence {
		if( !available ) return presence;
		presence = p;
		stream.sendPacket( presence );
		return presence;
	}
	*/
	
	/**
		Sets presence of all roster contacts to offline.
	*/
	public function setPresencesOffline() {
		for( entry in entries ) {
			entry.presence.type = "offline";//Presence.OFFLINE;
			onPresence( entry );
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
				
				for( item_xml in iq.ext.toXml().elements() ) {
					
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
							entries.push( entry );
							added.add( entry );
							
						} else { // update existing entry
							existing = entry;
							updated.add( entry );
						}
					}
				}
				
				if( !available ) {
					available = true;
					onAvailable( this );
					//change( new RosterEvent( stream, RosterEventType.available( this ) ) );
				}
				if( added.length > 0 )   onAdd( added );//change( new RosterEvent( stream, RosterEventType.added( added ) ) ); //onAdd( added );
				if( updated.length > 0 ) onUpdate( updated );//change( new RosterEvent( stream, RosterEventType.updated( updated ) ) );//onUpdate( updated );
				if( removed.length > 0 ) onRemove( removed );//change( new RosterEvent( stream, RosterEventType.removed( removed ) ) );//onRemove( removed );
			
			default :
				// TODO
			
		}
	}
	
	/**
		Handles incoming xmpp.Presence packets.
	*/
	public function handlePresence( presence : xmpp.Presence ) {
		
		if( !available ) return;
		
		var from = JIDUtil.parseBar( presence.from );
		var entry = getEntry( from );
		if( entry != null ) {
			
			trace("PRESENCE FROM ROSTER USER");		
			entry.presence = presence;
			onPresence( entry );
			//change( new RosterEvent( stream, RosterEventType.presence( entry ) ) );
			
		} else {
			trace("PRESENCE FROM NEW USER");
			
			if( presence.type == "subscribe" ) {
				switch( subscriptionMode ) {
				
					case rejectAll :
						var p = new Presence( "unsubscribed" );
						p.to = presence.from;
						stream.sendPacket( p );
						return;
						
					case acceptAll :
						if( subscriptionMode == SubscriptionMode.acceptAll ) { // allow subsription
							var p = new Presence( "subscribed" );
							p.to = presence.from;
							stream.sendPacket( p );
							subscribe( presence.from ); // subscribe too, automaticly
							//onPresence( entry );
						}
					case manual :
						//..
						//onPresence( entry );
				}
			} else if( presence.type == "unsubscribed" ) {
				
			}
			//...
			
		}
	}
	
	/**
		Creates a RosterEntry from given roster item xml.
	*/
	function createRosterEntry( xml : Xml ) : RosterEntry {
		var jid_str = xml.get( "jid" );
var resource = JIDUtil.parseResource( jid_str ); //TODO()
		var groups = new List<String>();
		for( group in xml.elementsNamed( "group" ) ) groups.add( group.firstChild().nodeValue );
		var e = new RosterEntry( this );
		e.jid = JIDUtil.parseBar( jid_str );
		e.subscription = RosterItem.getSubscriptionType( xml.get( "subscription" ) );
		e.name = xml.get( "name" );
		e.presence = null;
		e.askType = RosterItem.getAskType( xml.get( "ask" ) );
		e.groups = groups;
		return e;
		/*
		return {
			roster : this,
			jid : JIDUtil.parseBarAddress( jid_str ),
			subscription : RosterItem.getSubscriptionType( xml.get( "subscription" ) ),
			name : xml.get( "name" ),
			presence : null,
			askType : RosterItem.getAskType( xml.get( "ask" ) ),
			groups : groups,
			resource : resource //TODO
		};
		*/
	}
	
}
