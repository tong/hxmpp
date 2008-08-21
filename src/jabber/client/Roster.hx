package jabber.client;

import event.Dispatcher;
import jabber.core.PacketCollector;
import jabber.roster.SubscriptionMode;
import jabber.util.JIDUtil;
import xmpp.Presence;
import xmpp.IQ;
import xmpp.filter.IQFilter;
import xmpp.iq.Roster;



class RosterEntry extends jabber.roster.RosterEntry {
	public var roster : Roster;
	public function new() { super(); }
}


/**
	Jabber client roster.
*/
class Roster {
	
	public static var DEFAULT_SUBSCRIPTION_MODE = SubscriptionMode.acceptAll;
	
	public var onAvailable(default,null) : Dispatcher<Roster>;
	public var onAdd(default,null) 		 : Dispatcher<List<RosterEntry>>;
	public var onUpdate(default,null) 	 : Dispatcher<List<RosterEntry>>;
	public var onRemove(default,null) 	 : Dispatcher<List<RosterEntry>>;
	public var onPresence(default,null)  : Dispatcher<RosterEntry>;
	
	public var available(default,null) : Bool;
	public var presence(default,null) : Presence;
	public var entries(default,null) : List<RosterEntry>;
	public var groups(getGroups,null) : List<String>; 
	public var subscriptionMode : SubscriptionMode;
	public var stream(default,null) : Stream;


	public function new( stream : Stream ) {
		
		this.stream = stream;
		this.subscriptionMode = if( subscriptionMode == null ) DEFAULT_SUBSCRIPTION_MODE else subscriptionMode;
		
		available = false;
		presence = new Presence( "unavailable" );
		entries = new List();
		
		onAvailable = new Dispatcher();
		onAdd = new Dispatcher();
		onUpdate = new Dispatcher();
		onRemove = new Dispatcher();
		onPresence = new Dispatcher();
		
		// collect roster iq packets
		//stream.collectors.add( new PacketCollector( [new IQFilter( xmpp.iq.Roster.XMLNS )], handleRosterIQ, true ) );
		//trace(stream.collectors);
	}
	
	/*
	function setPresence( p : Presence ) : Presence {
		if( available ) {
			presence = p;
			stream.sendPacket( presence );
		}
		return presence;
	}
	*/
		
	function getGroups() : List<String> {
		var groups = new List<String>();
		for( entry in entries ) 
			for( group in entry.groups ) 
				for( g in groups ) 
					if( group != g ) groups.add( group );
		return groups;
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
	*/
	public function sendPresence( p : Presence ) : Presence {
		if( !available ) return presence;
		presence = p;
		stream.sendPacket( presence );
		return presence;
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
		Handles incoming xmpp.IQ (roster) packets.
	*/
	function handleRosterIQ( iq : xmpp.IQ ) {
		
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
				if( added.length > 0 ) onAdd.dispatchEvent( added );
				if( added.length > 0 ) onAdd.dispatchEvent( added );
				if( updated.length > 0 ) onUpdate.dispatchEvent( updated );
				if( removed.length > 0 ) onRemove.dispatchEvent( removed );
			
			default :
				// TODO
			
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
