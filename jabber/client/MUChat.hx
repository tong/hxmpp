package jabber.client;

import jabber.core.PacketCollector;
import jabber.core.PresenceManager;
import jabber.muc.Occupant;
import xmpp.MUC;
import xmpp.muc.Affiliation;
import xmpp.muc.Role;
import xmpp.Message;
import xmpp.MessageType;
import xmpp.PacketType;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketFromContainsFilter;
import xmpp.filter.PacketTypeFilter;


class MUChatMessage {
	
	public var muc(default,null) : MUChat;
	public var message(default,null) : xmpp.Message;
	public var occupant : Occupant;
	
	public function new( muc : MUChat, m : xmpp.Message, o : Occupant ) {
		this.muc = muc;
		this.message = m;
		this.occupant = o;
	}

}


/**
	Represents a multi user chatroom conversation.
	
	<a href="http://www.xmpp.org/extensions/xep-0045.html">XEP-0045: Multi-User Chat</a>
	<a href="http://www.xmpp.org/extensions/xep-0249.html">XEP-0249: Direct MUC Invitations</a>
*/
class MUChat {
	
	public dynamic function onJoin( muc : MUChat ) {}
	public dynamic function onMessage( msg : MUChatMessage ) {}
	public dynamic function onPresence( occupant : jabber.muc.Occupant ) {}
	public dynamic function onSubject( muc : MUChat ) {}
	
	public var stream(default,null) : Stream;
	public var jid(default,null) : String;
	public var joined(default,null)	: Bool;
	//public var locked(default,null) : Bool;
	public var myJid(default,null) : String;
	public var nick(default,null) : String;
	public var role : Role;
	public var affiliation : Affiliation;
	public var presence : PresenceManager;
	public var occupants : Array<jabber.muc.Occupant>;
	public var subject(default,null) : String;
	public var history(default,null) : Array<String>;//Array<MUCMessage>;
	public var historySize(default,setHistorySize) : Int;
	
	//public var service(default,setServiceDiscovery) : ServiceDiscovery;
	
	var message : xmpp.Message;
	var presenceCollector : PacketCollector;
	var messageCollector : PacketCollector;
	
	
	/**
	*/
	public function new( stream : Stream, host : String, roomName : String ) {
		
		this.stream = stream;
		this.jid = roomName+"@"+host;

		joined = false;
		presence = new PresenceManager( stream ); 
		occupants = new Array();
		history = new Array();
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
	//	if( s < history.length ) history = history.slice( history.length-s );
		return historySize = s;
	}
	
	
	/**
		Sends initial available presence to muc-room.
	*/
	public function join( nick : String, ?password : String ) : Bool {
		if( joined ) return false;
		if( nick == null || nick.length == 0 ) throw "Nickname must be not null or blank";
		this.nick = nick;
		myJid = jid+"/"+nick;
		var p = new xmpp.Presence();
		p.priority = 5;
		p.to = myJid;
		p.properties.push( xmpp.X.create( xmpp.MUC.XMLNS ) );
		stream.sendPacket( p );
		return true;
	}
	
	/**
		Sends unavailable presence to the room and returns the presence packet sent.
	*/
	public function leave() : xmpp.Presence {
		if( !joined ) return null;
		var p = new xmpp.Presence( xmpp.PresenceType.unavailable );
		p.to = myJid;
		presence.set( p );
		return p;
	}
	
	/**
		Sends message to all room occupants.
	*/
	public function speak( t : String ) : xmpp.Message {
		if( !joined ) return null;
		message.subject = null;
		message.body = t;
		return stream.sendPacket( message );
	}
	
	/*
	public function hasService( jid : String, handler :  ) {
		//service
	}*/
	
	public function changeSubject( t : String ) : xmpp.Message {
		if( !joined ) return null;
		//TODO check/role .. only moderators can change
		message.body = null;
		message.subject = t;
		return stream.sendPacket( message );
	}
	
	
	#if JABBER_DEBUG
	
	public function toString() : String {
		return "MUChat("+jid+")";
	}
	
	#end
	
	
		//TODO
	function handleMessage( m : xmpp.Message ) {
		if( !joined ) return;
		var from = parseName( m.from );
		var occupant = getOccupant( from );
		if( occupant == null && from != jid && from != nick && from != jid ) {
			trace( "??? Message from unknown muc occupant ??? "+from );
			return;
		}
		if( m.subject != null ) {
			if( subject != null ) {
				if( m.subject == subject ) return;
			}
			subject = m.subject;
			onSubject( this );
		}
		onMessage( new MUChatMessage( this, m, occupant ) );
	}
	
	function handlePresence( p : xmpp.Presence ) {
		
		var x_user = xmpp.MUCUser.parse( p.toXml() );
		if( x_user == null ) return;
		
		switch( p.from ) {
			
			case myJid :
				switch( p.type ) {
					
					case xmpp.PresenceType.unavailable : 
						joined = false;
						occupants = new Array();
						onJoin( this );
						
					case null :
						if( !joined ) {
							//.TODO check presence packet
							joined = true;
							onJoin( this );
							// unlock room if required
							if( x_user.item.role == Role.moderator &&
								x_user.status != null &&
								x_user.status.code == xmpp.muc.Status.WAITS_FOR_UNLOCK )
							{
								var iq = new xmpp.IQ( xmpp.IQType.set, null, jid );
								var q = new xmpp.MUCOwner().toXml();
								q.addChild( Xml.parse( '<x xmlns="jabber:x:data" type="submit" />' ) );
								//query.addChild( new xmpp.DataForm( xmpp.DataFormType.submit ).toXml() );
								iq.properties.push( q );
								stream.sendIQ( iq, function(iq) {
									if( iq.type == xmpp.IQType.result ) {
										trace("UNLOCKEDDDDD");
										//unlocked = true;
									}
								} );
							}
						}
				}
				
			case jid :
				trace("... process presence from room.");
				//TODO
				
			default : // process occupant presence
				var from = parseName( p.from );
				var occupant = getOccupant( from );
				if( occupant != null ) { // update existing occupant
					if( p.type == xmpp.PresenceType.unavailable ) {
						occupants.remove( occupant );
					}
					//..
					
				} else { // process new occupant
					occupant = new Occupant();
					occupant.nick = from;
					//occupant.jid = null;
					occupants.push( occupant );
				}
				occupant.presence = p;
				if( x_user.item.role != null ) occupant.role = x_user.item.role;
				if( x_user.item.affiliation != null ) occupant.affiliation = x_user.item.affiliation;
				onPresence( occupant );
		}
	}
	
	function getOccupant( n : String ) : jabber.muc.Occupant {
		for( o in occupants ) if( o.nick == n ) return o;
		return null;
	}
	
	inline function parseName( j : String ) : String {
		return j.substr( j.lastIndexOf( "/" ) + 1 );
	}
	
}
