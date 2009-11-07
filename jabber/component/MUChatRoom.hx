/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package jabber.component;

import jabber.stream.PacketCollector;

/**
*/
class HistoryMessage extends xmpp.Message {
	public var nick(default,null) : String;
	public function new( nick : String, body : String, from : String, stamp : String ) {
		super( null, body );
		type = xmpp.MessageType.groupchat;
		this.nick = nick;
		properties.push( new xmpp.Delayed( from, stamp ).toXml() );
	}
}

/**
*/
class History {
	
	public static var defaultHistoryLength : Int = 20;
	
	public var length(default,setLength) : Int;
	//public var currentLength(getCurrentLength,null) : Int;
	
	var messages : Array<HistoryMessage>;
	
	public function new( ?length : Int ) {
		clear();
		setLength( ( length !=null ) ? length : defaultHistoryLength );
	}
	
	function setLength( l : Int ) : Int {
		if( l < length )
			messages.splice( 0, length-l );
		return length = l;
	}
	
	public function push( m : HistoryMessage ) {
		if( messages.length+1 == length )
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
//class MUChatOccupant {
class Occupant {
	
	public var room : MUChatRoom;
	public var jid : String; // real JID
	public var nick : String;
	public var presenceType : xmpp.PresenceType;
	public var presenceShow : xmpp.PresenceShow ;
	public var affiliation : xmpp.muc.Affiliation;
	public var role : xmpp.muc.Role;
	public var item(getItem,null) : xmpp.muc.Item;
	
	public function new( room : MUChatRoom, jid : String, nick : String, presenceType : xmpp.PresenceType, ?presenceShow : xmpp.PresenceShow ) {
		this.room = room;
		this.jid = jid;
		this.nick = nick;
		this.presenceType = presenceType;
		this.presenceShow = presenceShow;
	}
	
	function getItem() : xmpp.muc.Item {
		return new xmpp.muc.Item( affiliation, role, null, jid );
	}
	
	public function toString() : String {
		return "MUChatOccupant("+jid+","+nick+","+presenceType+")";
	}
}


/**
	Chatroom for MUC services.
*/
class MUChatRoom {
	
	public static var defaultLockMessage = "This room is locked from entry until configuration is confirmed.";
	public static var defaultUnlockMessage = "This room is now unlocked.";
	
	public dynamic function onJoin( o : Occupant ) : Void;
	public dynamic function onLeave( o : Occupant ) : Void;
	public dynamic function onMessage( o : Occupant, m : xmpp.Message ) : Void;
//TODO	public dynamic function onPresence( room : MUChatRoom, m : xmpp.Presence ) : Void;
	public dynamic function onSubject( o : Occupant ) : Void;
	//..
	
	/** Room name */
	public var name(default,null) : String;
	/** Room JID */
	public var jid(default,null) : String;
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
	/** Chatroom subject */
	public var subject(default,null) : String;
	/** */
	public var locked(default,null) : Bool;
	/** JID of the room owner */
	public var owner(default,null) : Occupant;
	/** Message history */
	public var history(default,null) : History;
	/** */
	//public var isLogging : Bool; // 7.1.14 Room Logging
	/** */
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream, name : String,
						 ?password : String,
						 ?maxOccupants : Int = -1,
						 ?historyLength : Int) {
		
		// phpbug ?
//		if( password.length == 0 )
//			throw "Invalid password";
//		if( maxOccupants < 2 )
//			throw "Invalid max occupant length ("+maxOccupants+")";
			
		this.stream = stream;
		this.name = name;
		this.password = password;
		this.maxOccupants = maxOccupants;
		
		jid = name+"@"+stream.subdomain+"."+stream.host;
		occupants = new Hash();
		locked = true;
		history = new History( historyLength );
		
		// collect all packets addressed to the room
		var f : xmpp.PacketFilter = new xmpp.filter.PacketToContainsFilter( jid );
		stream.addCollector( new PacketCollector( [f], handlePacket, true ) );
	}
	
	/**
		Inject any packet for processing.
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
		var occupant = occupants.get( nick );
		var newOccupant = false;
		if( occupant == null ) { // new occupant
			if( p.type != null || p.type == xmpp.PresenceType.unavailable ) {
				//trace( "INVALID PRESENCE", "warn" );
				return;
			}
			trace( "NEW OCCUPANT", "info" );
			newOccupant = true;
			occupant = handleNewOccupant( nick, p );
			if( occupant == null ) {
				return;
			} else {
				onJoin( occupant );
			}
		} else {
			// handle occupant leave
			if( p.type == xmpp.PresenceType.unavailable ) {
				handleRoomLeave( occupant );
				return;
			}
		}
		// broadcast updated presence to all occupants
		publishPresence( occupant );
		// send message history to new occupant
		if( newOccupant ) {
			//trace("SÄND HISORY.." +Lambda.count(history) );
			for( m in history ) {
				m.from = roomJID( m.nick );
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
		if( occupant == null )
			return;
		if( m.subject != null ) {
			handleSubjectChange( occupant, m.subject );
		} else {
			// add message to history
			if( history.length != -1 )
				history.push( new HistoryMessage( occupant.nick, m.body, occupant.jid, xmpp.DateTime.toUTC( Date.now().toString() ) ) );
			// fire message event
			onMessage( occupant, m );
		}
		// broadcast message to all occupants
		m.from = roomJID( occupant.nick );
		publishMessage( m );
	}
	
	/**
		Force send message history.
	*/
	/*
	public function sendHistory( nick : String ) {
	<message
    from='darkcave@chat.shakespeare.lit/firstwitch'
    to='hecate@shakespeare.lit/broom'
    type='groupchat'>
  <body>Thrice the brinded cat hath mew'd.</body>
  <delay xmlns='urn:xmpp:delay'
     from='crone1@shakespeare.lit/desktop'
     stamp='2002-10-13T23:58:37Z'/>
</message>
	*/
		//trace("SEND HISTORY");
	/*
		var o = occupants.get( nick );
		trace("SEND HISTORY...................");
		trace(o);
		for( msg in history ) {
			msg.to = jid+"/"+o.nick;
			stream.sendData( msg.toString() );
		}
	}
		*/
	
	
	function handleIQ( iq : xmpp.IQ ) {
		if( locked ) {
			if( iq.from != owner.jid || iq.type != xmpp.IQType.set || iq.x == null || iq.x.toXml().firstElement() == null ) {
				return;
			}
			var x = xmpp.DataForm.parse( iq.x.toXml().firstElement() );
			if( x.type != xmpp.dataform.FormType.submit ) {
				return;
			}
			locked = false;
			stream.sendPacket( new xmpp.Message( iq.from, defaultUnlockMessage, null, xmpp.MessageType.groupchat, null, jid ) );
			stream.sendPacket( new xmpp.IQ( xmpp.IQType.result, iq.id, iq.from, jid ) );
			trace("ROOM UNLOCKED "+owner );
			return;
		}
		//...
	}
	
	function handleNewOccupant( nick : String, p : xmpp.Presence ) : Occupant {
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
			return null;
		}
		if( Lambda.count( occupants )+1 == maxOccupants ) {
			sendErrorPresence( p.from, xmpp.ErrorType.wait, xmpp.ErrorCondition.SERVICE_UNAVAILABLE );
			return null;
		}
		var occupant = new Occupant( this, p.from, nick, p.type, p.show );
		if( locked ) {
			owner = occupant;
			occupant.affiliation = xmpp.muc.Affiliation.owner;
			occupant.role = xmpp.muc.Role.moderator;
			occupants.set( nick, occupant );
			var r = new xmpp.Presence( null, null, null );
			r.to = p.from;
			r.from = roomJID( nick );
			r.properties.push( xmpp.X.create( xmpp.MUCUser.XMLNS, [ occupant.item.toXml(), new xmpp.muc.Status( 201 ).toXml()] ) );
			stream.sendPacket( r );
			var m = new xmpp.Message( p.from, defaultLockMessage, null, xmpp.MessageType.groupchat, null, jid );
			stream.sendPacket( m );
	//hm		
			//onJoin( occupant );
			for( m in history ) {
				m.to = occupant.jid;
				stream.sendData( m.toString() );
			}
			return null;
		} else {
			if( occupant.jid == owner.jid ) {
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
				presence.type = o.presenceType;
				presence.show = o.presenceShow;
				presence.from = roomJID( o.nick );
				presence.properties = [xmpp.X.create( xmpp.MUCUser.XMLNS, [o.item.toXml()] )];
				stream.sendPacket( presence );
			}
			occupants.set( nick, occupant );
			return occupant;
		}
	}
	
	function handleRoomLeave( occupant : Occupant ) {
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
		onLeave( occupant );
	}
	
	function publishPresence( occupant : Occupant ) {
		var p = new xmpp.Presence();
		p.type = occupant.presenceType;
		p.from = roomJID( occupant.nick );
		var x = xmpp.X.create( xmpp.MUCUser.XMLNS, [occupant.item.toXml()] );
		p.properties.push( x );
		for( o in occupants ) {
			p.to = o.jid;
			stream.sendPacket( p );
		}
	}
	
	function publishMessage( m : xmpp.Message ) {
		for( o in occupants ) {
			m.to = o.jid;
			stream.sendPacket( m );
		}
	}
	
	function handleSubjectChange( occupant : Occupant, subject : String ) {
		//TODO
		this.subject = subject;
		onSubject( occupant );
	}
	
	function sendErrorPresence( to : String, type : xmpp.ErrorType, name : String, x : Bool = true ) {
		var p = new xmpp.Presence( xmpp.PresenceType.error );
		p.from = jid;
		p.to = to;
		if( x ) p.properties.push( xmpp.X.create( xmpp.MUC.XMLNS ) );
		p.errors.push( new xmpp.Error( type, null, name ) );
		stream.sendPacket( p );
	}
	
	inline function roomJID( nick : String ) : String {
		return jid+"/"+nick;
	}
	
}
