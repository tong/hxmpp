package jabber.client;

import jabber.core.PacketCollector;
import jabber.muc.Affiliation;
import jabber.muc.Role;
import jabber.muc.Occupant;
import xmpp.Message;
import xmpp.MessageType;
import xmpp.PacketType;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketFromContainsFilter;
import xmpp.filter.PacketTypeFilter;


/*
private class PresenceManager {
	
	public function new() {
	}
	
}

class Occupant extends jabber.muc.Occupant {
}

*/


/**
	Represents a multi user chatroom conversation.
	
	<a href="http://www.xmpp.org/extensions/xep-0045.html">XEP-0045: Multi-User Chat</a>
	<a href="http://www.xmpp.org/extensions/xep-0249.html">XEP-0249: Direct MUC Invitations</a>
	
*/
class MUChat {
	
	public var stream(default,null) : jabber.client.Stream;
	public var jid(default,null) : String;
	public var joined(default,null)	: Bool;
	public var me(default,null) : jabber.muc.Occupant;
	//public var presence : PresenceManager;
	public var myJid(default,null) : String;
	//public var peers(default,null) : List<jabber.muc.Peer>;
	public var occupants : Array<jabber.muc.Occupant>;
	//public var history(default,null) : Array<MUChatMessage>;
	public var historySize(default,setHistorySize) : Int;
	
	var message : xmpp.Message;
	var presenceCollector : PacketCollector;
	var messageCollector : PacketCollector;
	
	
	public function new( stream : Stream, host : String, roomName : String ) {
		
		this.stream = stream;
		this.jid = roomName+"@"+host;

		joined = false;
		me = new Occupant();
		me.presence = new xmpp.Presence( xmpp.PresenceType.unavailable );   
		occupants = new Array();
		message = new Message( MessageType.groupchat, jid );
		
		// collect all presences and messages from the room jid
		var from_filter = new PacketFromContainsFilter( jid );
		presenceCollector = new PacketCollector( [cast from_filter, cast new PacketTypeFilter( PacketType.presence ) ], handlePresence, true );
		stream.collectors.add( presenceCollector );
		messageCollector = new PacketCollector(  [cast from_filter, cast new MessageFilter( MessageType.groupchat )], handleMessage, true );
		stream.collectors.add( messageCollector );
	}
	
	
	function setHistorySize( s : Int ) : Int {
		if( s < 0 ) s = 0;
		if( s < history.length ) history = history.slice( history.length-s );
		return historySize = s;
	}
	
	
	public dynamic function onJoin( muc : jabber.client.MUChat ) {}
	public dynamic function onMessage( m ) {}
	public dynamic function onPresence( occupant : jabber.muc.Occupant ) {}
	
	
	/**
		Sends initial available presence to muc-room.
	*/
	public function join( nickname : String, ?password : String ) {
		if( joined ) return;
		if( nickname == null || nickname.length == 0 ) throw "Nickname must be not null or blank";
		me.nick = nickname;
		myJid = jid + "/" + nickname;
		var  p = new xmpp.Presence();
		p.to = myJid;
		p.properties.push( Xml.parse( '<x xmlns="http://jabber.org/protocol/muc"/>' ).firstElement() );
		stream.sendPacket( p );
		/*
		*/
	}
	
	/**
		Sends unavailable presence.
	*/
	public function leave() {
		if( !joined ) return;
		//var p = new Presence( Presence.UNAVAILABLE, null, null, 0  );
		//p.to = myJid;
//		setPresence( p );
	}
	
	/**
		Sends message to all room occupants.
	*/
	public function speak( m : String ) {
		if( !joined ) return;
		message.body = m;
		stream.sendPacket( message );
	}
	
	#if JABBER_DEBUG
	
	public function toString() : String {
		return "MUChat("+jid+")";
	}
	
	#end
	
	
	function handleMessage( m : xmpp.Message ) {
		//TODO
		//trace("MUC MESSAGE: " );
		//if( joined ) {
			onMessage( m );
		//}
	}
	
	function handlePresence( p : xmpp.Presence ) {
		switch( p.from ) {
			
			case myJid :
				switch( p.type ) {
					case xmpp.PresenceType.unavailable : 
						joined = false;
					case null :
						if( !joined ) {
							joined = true;
						}
					onJoin( this );
				}
			case jid :
				trace("TODO process presence from room.");
			
			default : // process occupant presence
				var from = parseName( p.from );
				var occupant = getOccupant( from );
				if( occupant == null ) { // new occupant
					//
					occupant = new Occupant();//{ nickname : from, presence : p, role : null, affiliation : null };
					
					occupants.push( occupant );
				} else { // update existing occupant
					occupant = new Occupant();//{ nickname : from, presence : p, role : null, affiliation : null };
				}
				var x = parsePresenceX( p );
				if( x != null ) {
					if( x.role != null ) occupant.role = x.role;
					if( x.affiliation != null ) occupant.affiliation = x.affiliation;
				}
				onPresence( occupant );
		}
	}
	
	// TODO all namespaces
	function parsePresenceX( p : xmpp.Presence ) : { role : Role, affiliation : Affiliation } {
		var role : Role = null;
		var affiliation : Affiliation = null;
		for( p in p.properties ) {
			if( p.nodeName == "x" && p.get( "xmlns" ) == XMLNS_USER ) {
				for( item in p.elementsNamed( "item" ) ) {
					var r = item.get( "role" );
					if( r != null ) {
						role = switch( r ) {
							case "none" : Role.none;
							case "visitor" : Role.visitor;
							case "participant" : Role.participiant;
							case "moderator" : Role.moderator;
						}
					}
					var a = item.get( "affiliation" );
					if( a != null ) {
						affiliation = switch( a ) {
							case "none" : Affiliation.none;
							case "owner" : Affiliation.owner;
							case "admin" : Affiliation.admin;
							case "member" : Affiliation.member;
							case "outcast" : Affiliation.outcast;
						}
					}
				}
				//TODO
				//TODO parse: <status code='110'/>
				for( status in p.elementsNamed( "status" ) ) {
					var code = status.get( "code" );
					switch( code ) {
						case "110" : // indicates that this presence is from myself
						case "210" : // indicates that the my roomnick got changed
					}
				}
				////////// TODO
			}
		}
		return { role : role , affiliation : affiliation };
	}
	
	function getOccupant( nick : String ) : jabber.muc.Occupant {
		for( o in occupants ) if( o.nick == nick ) return o;
		return null;
	}
	
	inline function parseName( j : String ) : String {
		return j.substr( j.lastIndexOf( "/" ) + 1 );
	}
	
}
