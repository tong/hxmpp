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
package jabber.client;

import jabber.stream.PacketCollector;
import xmpp.Message;
import xmpp.MessageType;
import xmpp.PacketType;
import xmpp.muc.Affiliation;
import xmpp.muc.Role;
import xmpp.filter.MessageFilter;
import xmpp.filter.PacketFromContainsFilter;
import xmpp.filter.PacketTypeFilter;

/**
*/
class MUCOccupant {

	public var nick : String;
	public var jid : String;
	public var presence : xmpp.Presence;
	public var role : xmpp.muc.Role;
	public var affiliation : xmpp.muc.Affiliation;
	//var lastMessage : xmpp.Message;
	
	public function new() {}
}

/**
	Multiuser chatroom.
	<a href="http://www.xmpp.org/extensions/xep-0045.html">XEP-0045: Multi-User Chat</a>
	<a href="http://www.xmpp.org/extensions/xep-0249.html">XEP-0249: Direct MUC Invitations</a>
*/
class MUChat {

	public dynamic function onJoin() {}
	public dynamic function onLeave() {}
	public dynamic function onUnlock() {}
	public dynamic function onMessage( o : MUCOccupant, m : xmpp.Message ) {}
	//public dynamic function onRoomMessage( m : xmpp.Message ) {}
	public dynamic function onPresence( o : MUCOccupant ) {}
	public dynamic function onSubject( t : String ) {}
	public dynamic function onKick( nick : String ) {}
	public dynamic function onError( e : jabber.XMPPError ) {}
	
	public var jid(default,null) : String;
	public var room(default,null) : String;
	public var joined(default,null)	: Bool;
	//public var locked(default,null) : Bool;
	public var myjid(default,null) : String;
	public var nick(default,null) : String;
	public var password(default,null) : String;
	public var role(default,null) : Role;
	public var affiliation(default,null) : Affiliation;
	public var occupants(default,null) : Array<MUCOccupant>;
	public var subject(default,null) : String;
	public var me(getMe,null) : MUCOccupant;
	public var stream(default,null) : Stream;
	
	var presence : xmpp.Presence;
	var message : xmpp.Message;
	var c_presence : PacketCollector;
	var c_message : PacketCollector;
	
	public function new( stream : Stream, host : String, roomName : String ) {
		
		this.stream = stream;
		this.jid = roomName+"@"+host;
		this.room = roomName;

		stream.features.add( xmpp.MUC.XMLNS );
		stream.features.add( xmpp.MUCUser.XMLNS );
		
		// collect all presences and messages from the room
		var f_from : xmpp.PacketFilter = new PacketFromContainsFilter( jid );
		c_presence = new PacketCollector( [f_from, cast new PacketTypeFilter( PacketType.presence )], handlePresence, true );
		c_message = new PacketCollector(  [f_from, cast new MessageFilter()], handleMessage, true );
		//c_message = new PacketCollector(  [f_from, cast new MessageFilter( MessageType.groupchat )], handleMessage, true );
		
		message = new xmpp.Message( jid, null, null, MessageType.groupchat, null );
		joined = false;
		occupants = new Array();
	}
	
	function getMe() : MUCOccupant {
		var o = new MUCOccupant();
		o.role = role;
		o.presence = presence;
		o.nick = nick;
		o.jid = myjid;
		o.affiliation = affiliation;
		return o;
		/*
		return { role : role,
				 presence : presence,
				 nick : nick,
				 jid : myjid,
				 affiliation : affiliation };
		*/
	}
	
	public function getOccupant( nick : String ) : MUCOccupant {
		for( o in occupants ) { if( o.nick == nick ) return o; }
		return null;
	}
	
	/**
		Sends initial presence to room.
	*/
	//TODO?? public function join( nick : String, ?password : String, ?properites : Array<Xml> ) : Bool {
	public function join( nick : String, ?password : String ) : Bool {
		if( joined ||  nick == null || nick.length == 0 )
			return false;
		stream.addCollector( c_presence );
		stream.addCollector( c_message );
		this.nick = nick;
		this.password = password;
		myjid = jid+"/"+nick;
		return ( sendMyPresence() != null );
	}
	
	/**
		Sends unavailable presence to the room, exits room.
	*/
	public function leave( ?message : String, ?forceEvent : Bool = true ) : xmpp.Presence {
		if( !joined ) return null;
		var p = new xmpp.Presence( null, message, null, xmpp.PresenceType.unavailable );
		p.to = myjid;
		presence = p;
		stream.sendPacket( p );
		if( forceEvent )
			destroy();
		return p;
	}
	
	/**
	*/
	public function sendPresence( ?show : xmpp.PresenceShow, ?status : String, ?priority : Int, ?type : xmpp.PresenceType ) : xmpp.Presence {
		var p =  new xmpp.Presence( show, status, priority, type );
		p.to = myjid;
		p.properties.push( xmpp.X.create( xmpp.MUC.XMLNS ) );
		return stream.sendPacket( p );
	}
	
	/**
		Sends message to all room occupants.
	*/
	public function speak( t : String, ?properties : Array<Xml> ) : xmpp.Message {
		if( !joined ) return null;
		message.properties = ( properties == null ) ? [] : properties;
		message.subject = null;
		message.body = t;
		return stream.sendPacket( message );
	}
	
	/**
	*/
	public function changeSubject( t : String ) : xmpp.Message {
		if( !joined ) return null;
		//TODO check/role .. only moderators can change
		message.properties = [];
		message.body = null;
		message.subject = t;
		return stream.sendPacket( message );
	}
	
	/**
	*/
	public function changeNick( t : String ) : xmpp.Presence {
		if( !joined ) return null;
		if( t == null || t.length == 0 )
			throw "invalid nickname";
		nick = t;
		myjid = jid+"/"+nick;
		return sendMyPresence();
	}
	
	/**
	*/
	public function kick( nick : String, ?reason : String ) : Bool {
		if( !joined ) return false;
		// TODO check role
		var occupant = getOccupant( nick );
		if( occupant == null ) {
			#if JABBER_DEBUG trace("MUC occupant to kick not found","warn"); #end
			return false;
		}
		var iq = new xmpp.IQ( xmpp.IQType.set, null, myjid );
		var xt = new xmpp.MUCAdmin();
		var item = new xmpp.muc.Item();
		item.nick = nick;
		item.reason = reason;
		item.role = xmpp.muc.Role.none;
		xt.items.push( item );
		iq.x = xt;
		var me = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
			case result : me.onKick( nick );
			case error : me.onError( new jabber.XMPPError( r ) );
			default : // #
			}
		} );
		return true;
	}
	
	/**
		Sends an (mediated) invitation message to the given entity .
	*/
	public function invite( jid : String, ?reason : String ) {
		var m = new xmpp.Message( jid );
		var x = xmpp.X.create( xmpp.MUCUser.XMLNS );
		x.addChild( new xmpp.muc.Invite( jid, reason ).toXml() );
		m.properties.push( x );
		stream.sendPacket( m );
	}
	
	/*
	public function inviteDirect( jid : String, ?reason : String ) {
		var m = new xmpp.Message( jid );
		m.from = stream.jid.toString();
		var x = xmpp.X.create( "jabber:x:conference" );
		x.set( "jid", this.jid );
		if( reason != null ) x.set( "reason", reason ); 
		m.properties.push( x );
		stream.sendPacket( m );
	}
	*/
	
	function handleMessage( m : xmpp.Message ) {
		switch( m.type ) {
		case MessageType.groupchat :
			var from = getOccupantName( m.from );
			if( m.subject != null ) {
				if( m.subject == subject )
					return;
				onSubject( subject = m.subject );
				return;
			}
			var occupant = getOccupant( from );
			if( occupant == null && from != jid && from != nick ) {
				onMessage( null, m );
				return;
			}
			if( occupant == null && from == nick  ) occupant = me;
			onMessage( occupant, m );
		case MessageType.error :
			trace("TODO handle muc error");
		default :
		}
	}
	
	function handlePresence( p : xmpp.Presence ) {
		if( p.type == xmpp.PresenceType.error ) {
			onError( new jabber.XMPPError( p ) );
			return;
		}
		var x_user : xmpp.MUCUser = null;
		for( property in p.properties ) {
			if( property.nodeName == "x" && property.get( "xmlns" ) == xmpp.MUCUser.XMLNS ) {
				x_user = xmpp.MUCUser.parse( p.properties[0] );
			}
		}
		if( x_user == null )
			return;
		switch( p.from ) {
		case myjid :
			if( p.type == null ) {
				if( !joined ) {
					//TODO check for valid presence packet
					if( x_user.item != null ) {
						if( x_user.item.role != null ) role = x_user.item.role;
						if( x_user.item.affiliation != null ) affiliation = x_user.item.affiliation;
					}
					// unlock room if required
					//if( x_user.item != null ) {
					if( x_user.item.role == Role.moderator && x_user.status != null && x_user.status.code == xmpp.muc.Status.WAITS_FOR_UNLOCK ) {
						var iq = new xmpp.IQ( xmpp.IQType.set, null, jid );
						var q = new xmpp.MUCOwner().toXml();
						q.addChild( new xmpp.DataForm( xmpp.dataform.FormType.submit ).toXml() );
						iq.properties.push( q );
						var self = this;
						stream.sendIQ( iq, function(r:xmpp.IQ) {
							if( r.type == xmpp.IQType.result ) {
								#if JABBER_DEBUG trace( "Unlocked MUC room: "+self.room, "info" ); #end
								//unlocked = true; //TODO
								//self.onUnlock();
								self.joined = true;
								self.onJoin();
							}
						} );
					} else {
						joined = true;
						this.onJoin();
					}
				} else {
					// changed my nick
					role = x_user.item.role;
					affiliation = x_user.item.affiliation;
					presence = p;
					this.onPresence( me );
				}
				return;
			}
			switch( p.type ) {
			case xmpp.PresenceType.unavailable : 
				joined = false;
				destroy();
				//onLeave( this );
			//case null :
			default :
				trace("##############");
			}
		case jid :
			trace( "??? process presence from MUC room ???" );
			
		default : // process occupant presence
			var from = getOccupantName( p.from );
			var occupant = getOccupant( from );
			if( occupant != null ) { // update existing occupant
				if( p.type == xmpp.PresenceType.unavailable ) {
					occupants.remove( occupant );
				}
				//..
				
			} else { // process new occupant
				occupant = new MUCOccupant();
				occupant.nick = from;
				occupants.push( occupant );
			}
			occupant.presence = p;
			if( x_user.item != null ) {
				if( x_user.item.role != null ) occupant.role = x_user.item.role;
				if( x_user.item.affiliation != null ) occupant.affiliation = x_user.item.affiliation;
			}
			this.onPresence( occupant );
		}
	}
	
	function sendMyPresence( priority : Int = 5 ) : xmpp.Presence {
		var x = xmpp.X.create( xmpp.MUC.XMLNS );
		if( password != null ) {
			x.addChild( xmpp.XMLUtil.createElement( "password", this.password ) );
		}

		var p = new xmpp.Presence( null, null, priority );
		p.to = myjid;
		p.properties.push( xmpp.X.create( xmpp.MUC.XMLNS ) );

		return stream.sendPacket( p );
	}
	
	inline function getOccupantName( j : String ) : String {
		return j.substr( j.lastIndexOf( "/" )+1 );
	}
	
	function destroy() {
		stream.removeCollector( c_presence );
		stream.removeCollector( c_message );
		occupants = new Array();
		role = null;
		affiliation = null;
		presence = null;
		myjid = null;
		room = null;
		// TODO remove
		onLeave();
	}
	
}
