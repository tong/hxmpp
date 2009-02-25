package jabber.client;

import jabber.PresenceManager;
import jabber.core.PacketCollector;
import jabber.core.PacketCollector;
import xmpp.muc.Affiliation;
import xmpp.muc.Role;
import xmpp.Message;
import xmpp.MessageType;
import xmpp.PacketType;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketFromContainsFilter;
import xmpp.filter.PacketTypeFilter;


/**
*/
typedef MUCOccupant = {
	//TODO ? var muc : MUC;
	var nick : String;
	var jid : String;
	var presence : xmpp.Presence;
	var role : xmpp.muc.Role;
	var affiliation : xmpp.muc.Affiliation;
	//?? var lastMessage : xmpp.Message;
}


/**
	Multi-user chatroom from client perspective.
	
	<a href="http://www.xmpp.org/extensions/xep-0045.html">XEP-0045: Multi-User Chat</a><br>
	<a href="http://www.xmpp.org/extensions/xep-0249.html">XEP-0249: Direct MUC Invitations</a>
*/
class MUC {
	
	//TODO public static var defaultPresencePriority = 5;
	
	public dynamic function onJoin( muc : MUC ) {}
	public dynamic function onLeave( muc : MUC ) : Void;
	//TODO public dynamic function onRoomMessage( muc : MUC, m : xmpp.Message ) : Void;
	public dynamic function onMessage( muc : MUC, o : MUCOccupant, m : xmpp.Message ) : Void;
	public dynamic function onPresence( muc : MUC, o : MUCOccupant ) {}
	public dynamic function onSubject( muc : MUC ) : Void;
	
	public dynamic function onKick( muc : MUC, nick : String ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	public var jid(default,null) : String;
	public var room(default,null) : String;
	public var joined(default,null)	: Bool;
	//public var locked(default,null) : Bool;
	public var myjid(default,null) : String;
	public var nick(default,null) : String;
	public var role(default,null) : Role;
	public var affiliation(default,null) : Affiliation;
	public var presence(default,null) : PresenceManager;
	public var occupants(default,null) : Array<MUCOccupant>;
	public var subject(default,null) : String;
	public var me(getMe,null) : MUCOccupant;
	
	var message : xmpp.Message;
	var col_presence : PacketCollector;
	var col_message : PacketCollector;
	
	
	public function new( stream : Stream, host : String, roomName : String ) {
		
		this.stream = stream;
		this.jid = roomName+"@"+host;
		this.room = roomName;

		//TODO add to features
		stream.features.add( xmpp.MUC.XMLNS );
		stream.features.add( xmpp.MUCUser.XMLNS );
		
		//presence = new PresenceManager( stream, myjid );
		message = new xmpp.Message( jid, null, null, MessageType.groupchat, null );
		joined = false;
		occupants = new Array();
		
		// collect all presences and messages from the room
		var f_from : xmpp.PacketFilter = new PacketFromContainsFilter( jid );
		col_presence = new PacketCollector( [f_from, cast new PacketTypeFilter( PacketType.presence )], handlePresence, true );
		col_message = new PacketCollector(  [f_from, cast new MessageFilter( MessageType.groupchat )], handleMessage, true );
	}

	
	function getMe() : MUCOccupant {
		return { role : role, presence : presence.last, nick : nick, jid : myjid, affiliation : affiliation };
	}
	
	
	/**
		Sends initial presence to room.
	*/
	public function join( nick : String, ?password : String ) : Bool {
		if( joined ) return false;
		if( nick == null || nick.length == 0 ) throw new error.Exception( "Nickname must be not null or blank" );
		stream.addCollector( col_presence );
		stream.addCollector( col_message );
		this.nick = nick;
		myjid = jid+"/"+nick;
		return ( sendMyPresence() != null );
	}
	
	/**
		Sends unavailable presence to the room, exits room.
	*/
	public function leave( ?message : String, ?forceEvent : Bool = true ) : xmpp.Presence {
		if( !joined ) return null;
		trace( presence.target );
		var p = new xmpp.Presence( xmpp.PresenceType.unavailable, null, message );
		presence.set( p );
		if( forceEvent ) dispose();
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
	
	/**
	*/
	public function changeSubject( t : String ) : xmpp.Message {
		if( !joined ) return null;
		//TODO check/role .. only moderators can change
		message.body = null;
		message.subject = t;
		return stream.sendPacket( message );
	}
	
	/**
	*/
	public function changeNick( nick : String ) : xmpp.Presence {
		if( !joined ) return null;
		if( nick == null || nick.length == 0 ) throw new error.Exception( "Nickname must be not null or blank" );
		this.nick = nick;
		myjid = jid+"/"+nick;
		return sendMyPresence();
	}
	
	/**
	*/
	public function kick( nick : String, ?reason : String ) : Bool {
		if( !joined ) return false;
		var occupant = getOccupant( nick );
		trace(occupant);
		if( occupant == null ) {
			trace("OCC not found, canot kick");
			return false;
		}
		var iq = new xmpp.IQ( xmpp.IQType.set, null, myjid );
		var xt = new xmpp.MUCAdmin();
		var item = new xmpp.muc.Item();
		item.nick = nick;
		item.reason = reason;
		item.role = xmpp.muc.Role.none;
		xt.items.push( item );
		iq.ext = xt;
		var me = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
				case result : me.onKick( me, nick );
				case error : me.onError( new jabber.XMPPError( me, r ) );
				default : // #
			}
		} );
		return true;
	}
	
	/**
		Sends an invitation message to the given entity.
		//TODO
	*/
	public function invite( jid : String, ?reason : String ) {
		//if( !joined ) return false;
		//if( !jabber.JIDUtil.isValid( jid ) )
		var x = xmpp.X.create( xmpp.MUCUser.XMLNS, new xmpp.muc.Invite( reason, jid ).toXml() );
		var m = new xmpp.Message( this.jid );
		m.properties.push( x );
		stream.sendPacket( m );
	}
	
	
	function handleMessage( m : xmpp.Message ) {
		//trace("hääändleMessage-hääändleMessage-hääändleMessage-hääändleMessage-hääändleMessage");
		var from = getOccupantName( m.from );
		var occupant = getOccupant( from );
		if( occupant == null && from != jid && from != nick ) {
			trace( "??? Message from unknown muc occupant ??? "+from );
			return;
		}
		if( m.subject != null ) {
			if( subject != null && m.subject == subject ) return;
			subject = m.subject;
			onSubject( this );
			return;
		}
		if( occupant == null && from == nick  ) occupant = me;
		onMessage( this, occupant, m );
	}
	
	function handlePresence( p : xmpp.Presence ) {
		var x_user : xmpp.MUCUser = null;
		for( property in p.properties ) {
			if( property.nodeName == "x" && property.get( "xmlns" ) == xmpp.MUCUser.XMLNS ) {
				x_user = xmpp.MUCUser.parse( p.properties[0] );
			}
		}
		if( x_user == null ) return;
		switch( p.from ) {
			
			case myjid :
				switch( p.type ) {
					
					case xmpp.PresenceType.unavailable : 
						joined = false;
						dispose();
						//onLeave( this );
						
					case null :
						if( !joined ) {
							//TODO check for valid presence packet
							if( x_user.item != null ) {
								if( x_user.item.role != null ) role = x_user.item.role;
								if( x_user.item.affiliation != null ) affiliation = x_user.item.affiliation;
							}
							presence = new PresenceManager( stream, myjid );
							joined = true;
							this.onJoin( this );
							// unlock room if required
//							trace(">>>>>>>>>>>>>>>>>>>> "+x_user.item );
						//	if( x_user.item != null ) {
								if( x_user.item.role == Role.moderator &&
									x_user.status != null &&
									x_user.status.code == xmpp.muc.Status.WAITS_FOR_UNLOCK )
								{
									var iq = new xmpp.IQ( xmpp.IQType.set, null, jid );
									var q = new xmpp.MUCOwner().toXml();
									//TODO
									//query.addChild( new xmpp.DataForm( xmpp.DataFormType.submit ).toXml() );
									q.addChild( Xml.parse( '<x xmlns="jabber:x:data" type="submit"/>' ) );
									iq.properties.push( q );
									stream.sendIQ( iq, function(r) {
										if( r.type == xmpp.IQType.result ) {
											trace(" UNLOCKED MUC ROOM ");
											//unlocked = true; //TODO
										}
									} );
								}
						//	}
							
						} else {
							// changed my nick
							role = x_user.item.role;
							affiliation = x_user.item.affiliation;
							presence.target = myjid;
							onPresence( this, me );
						}
				}
				
			case jid :
				trace("... process presence from room.");
				
			default : // process occupant presence
				var from = getOccupantName( p.from );
				var occupant = getOccupant( from );
				if( occupant != null ) { // update existing occupant
					if( p.type == xmpp.PresenceType.unavailable ) {
						occupants.remove( occupant );
					}
					//..
					
				} else { // process new occupant
					occupant = { role : null, presence : null, nick : from, jid : null, affiliation : null };
					occupants.push( occupant );
				}
				occupant.presence = p;
				if( x_user.item != null ) {
					if( x_user.item.role != null ) occupant.role = x_user.item.role;
					if( x_user.item.affiliation != null ) occupant.affiliation = x_user.item.affiliation;
				}
				onPresence( this, occupant );
		}
	}
	
	function sendMyPresence( priority : Int = 5 ) : xmpp.Presence {
		var p = new xmpp.Presence( null, null, null, priority );
		p.to = myjid;
		p.properties.push( xmpp.X.create( xmpp.MUC.XMLNS ) );
		return stream.sendPacket( p );
	}
	
	function getOccupant( n : String ) : MUCOccupant {
		for( o in occupants ) {
			if( o.nick == n ) return o;
		}
		return null;
	}
	
	inline function getOccupantName( j : String ) : String {
		return j.substr( j.lastIndexOf( "/" ) + 1 );
	}
	
	function dispose() {
		stream.removeCollector( col_presence );
		stream.removeCollector( col_message );
		occupants = new Array();
		role = null;
		affiliation = null;
		presence = null;
		myjid = null;
		room = null;
		// TODO remove
		onLeave( this );
	}
	
}
