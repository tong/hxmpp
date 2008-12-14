package jabber.client;

import jabber.core.PacketCollector;
import jabber.core.PresenceManager;
import jabber.muc.Occupant;
import xmpp.muc.Affiliation;
import xmpp.muc.Role;
import xmpp.Message;
import xmpp.MessageType;
import xmpp.PacketType;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketFromContainsFilter;
import xmpp.filter.PacketTypeFilter;


class MUCMessage {
	
	public var muc(default,null) : MUC;
	public var xmpp(default,null) : xmpp.Message;
	public var occupant(default,null) : Occupant;
	
	public function new( muc : MUC, m : xmpp.Message, o : Occupant ) {
		this.muc = muc;
		this.xmpp = m;
		this.occupant = o;
	}
	/*
	#if JABBER_DEBUG
	public function toString() : String {
		return "MUCMessage(room=>"+muc.room+")";
	}
	#end
	*/
}


/**
	Represents a multi user chatroom conversation.
	
	<a href="http://www.xmpp.org/extensions/xep-0045.html">XEP-0045: Multi-User Chat</a>
	<a href="http://www.xmpp.org/extensions/xep-0249.html">XEP-0249: Direct MUC Invitations</a>
*/
class MUC {
	
	public dynamic function onJoin( muc : MUC ) {}
	public dynamic function onLeave( muc : MUC ) : Void;
	public dynamic function onMessage( msg : MUCMessage ) : Void;
	//public dynamic function onMessage( muc : MUC, o : Occupant, p : xmpp.Message ) : Void;
	public dynamic function onPresence( o : jabber.muc.Occupant ) {}
	public dynamic function onSubject( muc : MUC ) : Void;
	
	public var stream(default,null) : Stream;
	public var jid(default,null) : String;
	public var room(default,null) : String;
	public var joined(default,null)	: Bool;
	//public var locked(default,null) : Bool;
	public var myJid(default,null) : String;
	public var me(default,null) : Occupant;
//	public var nick(default,null) : String;
//	public var role : Role;
	//public var affiliation : Affiliation;
	public var presence : PresenceManager;
	public var occupants : Array<jabber.muc.Occupant>;
	public var subject(default,null) : String;
	//public var service(default,setServiceDiscovery) : MUChatDiscovery;
	
	var message : xmpp.Message;
	var col_presence : PacketCollector;
	var col_message : PacketCollector;
	
	
	public function new( stream : Stream, host : String, roomName : String ) {
		
		this.stream = stream;
		this.jid = roomName+"@"+host;
		this.room = roomName;

		joined = false;
		presence = new PresenceManager( stream ); 
		occupants = new Array();
//		history = new Array();
		message = new Message( MessageType.groupchat, jid );
		
		me = new Occupant();
		me.presence = new xmpp.Presence( xmpp.PresenceType.unavailable );
		
		// collect all presences and messages from the room jid
		var f_from : xmpp.filter.PacketFilter = new PacketFromContainsFilter( jid );
		col_presence = new PacketCollector( [f_from, cast new PacketTypeFilter( PacketType.presence ) ], handlePresence, true );
		stream.collectors.add( col_presence );
		col_message = new PacketCollector(  [f_from, cast new MessageFilter( MessageType.groupchat )], handleMessage, true );
		stream.collectors.add( col_message );
	}
	
	/*
	function getMe() : Occupant {
		var o = new Occupant();
		o.nick = nick;
		o.jid = myJid;
		o.presence = presence.get();
		if( o.presence == null ) trace("öööööööööööööööööööööööööööööööööööö");
		o.role = role;
		o.affiliation = affiliation;
		return o;
	}
	*/
	
	/**
	*/
	public function destroy() {
		if( joined ) return false;
		stream.collectors.remove( col_presence );
		stream.collectors.remove( col_message );
		return true;
	}
	
	/**
		Sends initial available presence to muc-room.
	*/
	public function join( nick : String, ?password : String ) : Bool {
		if( joined ) return false;
		if( nick == null || nick.length == 0 ) throw new error.Exception( "Nickname must be not null or blank" );
		me.nick = nick;
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
	public function leave( ?message : String, ?forceEvent : Bool = false ) : xmpp.Presence {
		if( !joined ) return null;
		var p = new xmpp.Presence( xmpp.PresenceType.unavailable, null, message );
		p.to = myJid;
		presence.set( p );
		if( forceEvent ) onLeave( this );
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
	/*
	public function toString() : String {
		return "MUChat("+jid+")";
	}
	*/
	#end
	
	
	//TODO
	function handleMessage( m : xmpp.Message ) {
		trace("händleMessage");
	//	if( !joined ) return;
		var from = getOccupantName( m.from );
		var occupant = getOccupant( from );
		if( occupant == null && from != jid && from != me.nick ) {
			trace( "??? Message from unknown muc occupant ??? "+from );
			return;
		}
		if( occupant == null ) {
			if( from == me.nick ) {
				occupant = me;
			}
		}
		if( m.subject != null ) {
			if( subject != null && m.subject == subject ) return;
			subject = m.subject;
			onSubject( this );
			return;
		}
		onMessage( new MUCMessage( this, m, occupant ) );
	}
	
	function handlePresence( p : xmpp.Presence ) {
		
		trace("händlePresence");
		
		var x_user = xmpp.MUCUser.parse( p.toXml() );
		if( x_user == null ) return;
		
		switch( p.from ) {
			
			case myJid :
			
				switch( p.type ) {
					
					case xmpp.PresenceType.unavailable : 
						joined = false;
						occupants = new Array();
						onLeave( this ); //onJoin( this );
						trace("<>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
						
					case null :
						if( !joined ) {
							//.TODO check presence packet
							joined = true;
							this.onJoin( this );
							// unlock room if required
							if( x_user.item.role == Role.moderator &&
								x_user.status != null &&
								x_user.status.code == xmpp.muc.Status.WAITS_FOR_UNLOCK )
							{
								var iq = new xmpp.IQ( xmpp.IQType.set, null, jid );
								var q = new xmpp.MUCOwner().toXml();
								//TODO
								//query.addChild( new xmpp.DataForm( xmpp.DataFormType.submit ).toXml() );
								q.addChild( Xml.parse( '<x xmlns="jabber:x:data" type="submit" />' ) );
								iq.properties.push( q );
								stream.sendIQ( iq, function(iq) {
									if( iq.type == xmpp.IQType.result ) {
										trace("UNLOCKED MUC ROOM");
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
				var from = getOccupantName( p.from );
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
				try {
					this.onPresence( occupant );
				} catch( e : Dynamic ) {
					trace("################################");
					trace(e);
				}
		}
	}
	
	function getOccupant( n : String ) : jabber.muc.Occupant {
		for( o in occupants ) if( o.nick == n ) return o;
		return null;
	}
	
	inline function getOccupantName( j : String ) : String {
		return j.substr( j.lastIndexOf( "/" ) + 1 );
	}
	
}
