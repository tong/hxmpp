package jabber.component;

import jabber.stream.PacketCollector;


private class HistoryMessage extends xmpp.Message {
	public function new( roomJID : String, from : String, body : String, stamp : String ) {
		super( null, body, null, xmpp.MessageType.groupchat, null, roomJID );
		properties.push( new xmpp.Delayed( from, stamp ).toXml() );
	}
}

private class History {
	
	public var maxLength(default,setMaxLength) : Int; //TODO setMaxLength
	var messages : Array<HistoryMessage>;
	
	public function new( maxLength : Int ) {
		clear();
		setMaxLength( maxLength );
	}
	
	function setMaxLength( l : Int ) : Int {
		if( l < maxLength ) {
			messages.splice( 0, maxLength-l );
		}
		return maxLength = l;
	}
	
	public function push( m : HistoryMessage ) {
		if( messages.length+1 == maxLength )
			messages.shift();
		messages.push( m ); 
	}
	
	public function clear() {
		messages = new Array<HistoryMessage>();
	}
	
	public function iterator() : Iterator<HistoryMessage> {
		return messages.iterator();
	}
	
}

//TODO 
//interface Occupant {

private class Occupant {
	
	public var jid : String;
	public var nick : String;
	public var presenceType : xmpp.PresenceType;
	public var presenceShow : String;
	public var affiliation : xmpp.muc.Affiliation;
	public var role : xmpp.muc.Role;
	public var item(getItem,null) : xmpp.muc.Item;
	
	public function new( jid : String, nick : String, presenceType : xmpp.PresenceType, ?presenceShow : String ) {
		this.jid = jid;
		this.nick = nick;
		this.presenceType = presenceType;
		this.presenceShow = presenceShow;
	}
	
	function getItem() : xmpp.muc.Item {
		return new xmpp.muc.Item( affiliation, role, null, jid );
	}
}

/**
	Represents a chatroom for muc services.
*/
class MUChatRoom {
	
	public static var defaultLockMessage = "This room is locked from entry until configuration is confirmed.";
	public static var defaultUnlockMessage = "This room is now unlocked.";
	public static var defaultHistoryLength : Int = 20;
	
	public dynamic function onMessage( room : MUChatRoom, m : xmpp.Message ) : Void;
	public dynamic function onPresence( room : MUChatRoom, m : xmpp.Presence ) : Void;
	
	/** Room name */
	public var name(default,null) : String;
	/** Room JID */
	public var jid(default,null) : String; //TODO jabber.JID
	/** Hash of room occupants */
	public var occupants(default,null) : Hash<Occupant>;
	/** Max occupants allowed in room, default is infinite (-1) */
	public var maxOccupants(default,null) : Int;
	/** The password required to enter the room, default is no (null) */
	public var password(default,null) : String;
	/** */
	//public var anonymous : AnonymousType;
	/** List of jids which are allowed to enter the room */
	//public var members(default,null) : List<String>;
	/** List of banned jids */
	//public var banned(default,null) : List<String>;
	/** */
	public var subject(default,null) : String;
	/** */
	public var locked(default,null) : Bool;
	/** JID of the room owner */
	public var owner(default,null) : String;
	/** */
	public var history : History;
	//public var isLogging : Bool; // 7.1.14 Room Logging
	
	public var stream(default,null) : Stream;
	
	
	public function new( stream : Stream, name : String,
						 ?password : String, ?maxOccupants : Int = -1, ?historyLength : Int = -1 ) {
		
		if( password == "" )
			throw "Invalid password";
		if( maxOccupants < 2 )
			throw "Invalid max occupant length ("+maxOccupants+")";
			
		this.stream = stream;
		this.name = name;
		this.password = password;
		this.maxOccupants = maxOccupants;
		
		jid = name+"@"+stream.subdomain+"."+stream.host;
		occupants = new Hash();
		locked = true;
		history = new History( ( historyLength != -1  ) ? historyLength : defaultHistoryLength );
		
		// collect all packets addressed to the room
		var f_to : xmpp.PacketFilter = new xmpp.filter.PacketToContainsFilter( jid );
		stream.addCollector( new PacketCollector( [f_to], handlePacket, true ) );
	}
	
	
	/**
		Inject a packet to handle.
	*/
	public function handlePacket( p : xmpp.Packet ) {
		switch( p._type ) {
		case presence : handlePresence( cast p );
		case message : handleMessage( cast p );
		case iq : handleIQ( cast p );
		case custom : //#
		}
	}

	/**
		Inject a presence packet to handle.
	*/
	public function handlePresence( p : xmpp.Presence ) {
		
		var nick = jabber.MUCUtil.getOccupant( p.to );
		if( nick == null ) {
			sendErrorPresence( p.from, xmpp.ErrorType.modify, xmpp.ErrorCondition.JID_MALFORMED, false );
			return;
		}
		
		trace(">>>>>>>>>>>>>>: "+nick );
		
		var occupant = occupants.get( nick );
		var newOccupant = false;
		
		// new occupant
		if( occupant == null ) {
			if( p.type != null || p.type == xmpp.PresenceType.unavailable ) {
				trace( "INVALID PRESENCE", "warn" );
				return;
			}
			trace( "NEW OCCUPANT", "info" );
			newOccupant = true;
			var hasMUCExt = false;
			for( prop in p.properties ) {
				if( prop.nodeName == "x" && prop.get( "xmlns" ) == xmpp.MUC.XMLNS ) {
					hasMUCExt = true;
					if( password != null ) {
						//TODO check for password
						//......
					}
					break;
				}
			}
			if( !hasMUCExt ) {
				//TODO notify client
				return;
			}
			if( Lambda.count( occupants )+1 == maxOccupants ) {
				sendErrorPresence( p.from, xmpp.ErrorType.wait, xmpp.ErrorCondition.SERVICE_UNAVAILABLE );
				return;
			}
			occupant = new Occupant( p.from, nick, p.type, p.show );
			occupants.set( nick, occupant );
			if( locked ) {
				owner = occupant.jid;
				occupant.affiliation = xmpp.muc.Affiliation.owner;
				occupant.role = xmpp.muc.Role.moderator;
				var r = new xmpp.Presence( null, null, null/*, p.priority*/ );
				r.to = p.from;
				r.from = roomJID( nick );
				r.properties.push( xmpp.X.create( xmpp.MUCUser.XMLNS, [ occupant.item.toXml(), new xmpp.muc.Status( 201 ).toXml()] ) );
				stream.sendPacket( r );
				var m = new xmpp.Message( p.from, defaultLockMessage, null, xmpp.MessageType.groupchat, null, jid );
				stream.sendPacket( m );
				return;
			} else {
				if( occupant.jid == owner ) {
					occupant.affiliation = xmpp.muc.Affiliation.owner;
					occupant.role = xmpp.muc.Role.moderator;
				} else {
					occupant.affiliation = xmpp.muc.Affiliation.member;
					occupant.role = xmpp.muc.Role.participant;
				}
				// send presences from existing occupants to new occupant
				var presence = new xmpp.Presence();
				presence.to = occupant.jid;
				for( o in occupants ) {
					if( o.jid != occupant.jid ) {
						presence.type = o.presenceType;
						presence.show = o.presenceShow;
						presence.from = roomJID( o.nick );
						presence.properties = [xmpp.X.create( xmpp.MUCUser.XMLNS, [o.item.toXml()] )];
						stream.sendPacket( presence );
					}
				}
			}
		}
		
		if( !newOccupant && p.type == xmpp.PresenceType.unavailable ) {
			//trace("OCCUPANT LEFT ROOM");
			occupants.remove( occupant.nick );
			var presence = new xmpp.Presence();
			presence.type = xmpp.PresenceType.unavailable;
			presence.from = roomJID( occupant.nick );
			var x = xmpp.X.create( xmpp.MUCUser.XMLNS, [occupant.item.toXml()] );
			presence.properties.push( x );
			for( o in occupants ) {
				presence.to = o.jid;
				stream.sendPacket( presence );
			}
			return;
		}
		
		// send updated presence to all occupants
		var presence = new xmpp.Presence();
		presence.type = occupant.presenceType;
		presence.from = roomJID( occupant.nick );
		var x = xmpp.X.create( xmpp.MUCUser.XMLNS, [occupant.item.toXml()] );
		presence.properties.push( x );
		for( o in occupants ) {
			presence.to = o.jid;
			stream.sendPacket( presence );
		}
		
		// send message history to new occupant
		if( newOccupant ) {
			for( m in history ) {
				m.to = occupant.jid;
				stream.sendData( m.toString() );
			}
		}
	}
	
	/**
		Inject a message packet to handle.
	*/
	public function handleMessage( m : xmpp.Message ) {
		if( m.type != xmpp.MessageType.groupchat )
			return;
		var occupant : Occupant = null;
		for( o in occupants ) {
			if( o.jid == m.from ) {
				occupant = o;
				break;
			}
		}
		if( occupant == null ) {
			return;
		}
		if( m.subject != null )
			subject = m.subject;
		
		// add message to history
		if( history.maxLength != -1 )
			history.push( new HistoryMessage( roomJID( occupant.nick ), occupant.jid, m.body, xmpp.DateTime.format( Date.now().toString() ) ) );
		
		// send message to all occupants
		m.from = roomJID( occupant.nick );
		for( o in occupants ) {
			m.to = o.jid;
			stream.sendPacket( m );
		}
	}
	
	
	function handleIQ( iq : xmpp.IQ ) {
		if( locked ) {
			if( iq.from != owner || iq.type != xmpp.IQType.set || iq.ext == null || iq.ext.toXml().firstElement() == null ) {
				return;
			}
			var x = xmpp.DataForm.parse( iq.ext.toXml().firstElement() );
			if( x.type != xmpp.dataform.FormType.submit ) {
				return;
			}
			locked = false;
			stream.sendPacket( new xmpp.Message( iq.from, defaultUnlockMessage, null, xmpp.MessageType.groupchat, null, jid ) );
			stream.sendPacket( new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from, jid ) );
			trace("ROOM UNLOCKED");
			return;
		}
		//...
	}
	
	function roomJID( nick : String ) : String {
		return jid+"/"+nick;
	}
	
	function sendErrorPresence( to : String, type : xmpp.ErrorType, name : String, x : Bool = true ) {
		var p = new xmpp.Presence( xmpp.PresenceType.error );
		p.from = jid;
		p.to = to;
		if( x )
			p.properties.push( xmpp.X.create( xmpp.MUC.XMLNS ) );
		p.errors.push( new xmpp.Error( type, null, name ) );
		stream.sendPacket( p );
	}
	
}
