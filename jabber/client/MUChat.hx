package jabber.client;

import jabber.core.PacketCollector;
import jabber.muc.Affiliation;
import jabber.muc.Peer;
import jabber.muc.Role;
import xmpp.Message;
import xmpp.PacketType;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketFromContainsFilter;
import xmpp.filter.PacketTypeFilter;


/**
	<a href="http://www.xmpp.org/extensions/xep-0045.html">XEP-0045: Multi-User Chat</a>
	
TODO http://xmpp.org/extensions/xep-0249.html
	
	Represents a multi user chatroom conversation.
*/
class MUChat {
	
	public static inline var XMLNS_USER = "http://jabber.org/protocol/muc#user";
	
	public var stream(default,null) : jabber.client.Stream;
	public var jid(default,null) : String;
	public var joined(default,null)	: Bool;
	public var me(default,null) : jabber.muc.Peer;
	public var myJid(default,null) : String;
	public var peers(default,null) : List<jabber.muc.Peer>;
	//public var history(default,null) : Array<MUChatMessage>;
	public var historySize(default,setHistorySize) : Int;
	
	var message : xmpp.Message;
	var presenceCollector : PacketCollector;
	var messageCollector : PacketCollector;
	
	
	public function new( stream : Stream, host : String, roomName : String ) {
		
		this.stream = stream;
		this.jid = roomName+"@"+host;
		/*
		this.room = {
			jid : roomName+"@"+host,
			description : null,
			subject : null,
			peers : new List<Peer>(),
			membersOnly : false,
			moderated : false,
			nonanonymous : false,
			passwordProtected : false,
			persistent : false,
		};
		*/
		
		joined = false;
		me = { nickname : null,
			   presence : new xmpp.Presence( "offline" ),
			   role : null, affiliation : null };
		peers = new List();
		message = new Message( MessageType.groupchat, jid );
		
		// collect all presences and messages from the room jid
		var from_filter = new PacketFromContainsFilter( jid );
		presenceCollector = new PacketCollector( [cast from_filter, cast new PacketTypeFilter( PacketType.presence ) ], handlePresence, true );
		stream.collectors.add( presenceCollector );
		messageCollector = new PacketCollector(  [cast from_filter, cast new MessageFilter( MessageType.groupchat )], handleMessage, true );
		stream.collectors.add( messageCollector );
	}
	
	
	function setHistorySize( s : Int ) : Int {
		//..TODO
		return s;
	}
	
	
	public dynamic function onJoin( muc : jabber.client.MUChat ) {}
	public dynamic function onMessage( m ) {}
	public dynamic function onPresence( peer : jabber.muc.Peer ) {}
	
	
	/**
		Sends initial available presence to muc-room.
	*/
	public function join( nickname : String, ?password : String ) {
		if( joined ) return;
		if( nickname == null || nickname.length == 0 ) throw "Nickname must be not null or blank";
		me.nickname = nickname;
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
		return "MUChat()";
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
					case "unavailable" : 
						joined = false;
					case null, "available" :
						if( !joined ) {
							joined = true;
						}
					onJoin( this );
				}
				
			default : // process occupant presence
				var from = parseName( p.from );
				var peer = getPeer( from );
				if( peer == null ) { // new occupant
					peer = { nickname : from, presence : p, role : null, affiliation : null };
					peers.add( peer );
				} else { // update existing occupant
					peer = { nickname : from, presence : p, role : null, affiliation : null };
				}
				var x = parsePresenceX( p );
				if( x != null ) {
					if( x.role != null ) peer.role = x.role;
					if( x.affiliation != null ) peer.affiliation = x.affiliation;
				}
				onPresence( peer );
		}
	}
	
	
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
	
	function getPeer( nickname : String ) : jabber.muc.Peer {
		for( p in peers ) if( p.nickname == nickname ) return p;
		return null;
	}
	
	inline function parseName( j : String ) : String {
		return j.substr( j.lastIndexOf( "/" ) + 1 );
	}
	
}
