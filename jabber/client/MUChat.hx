/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber.client;

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

	http://www.xmpp.org/extensions/xep-0045.html
	http://www.xmpp.org/extensions/xep-0249.html
*/
class MUChat {

	public dynamic function onJoin() {}
	public dynamic function onLeave() {}
	public dynamic function onUnlock() {}
	public dynamic function onMessage( o : MUCOccupant, m : xmpp.Message ) {}
	//public dynamic function onRoomMessage( m : xmpp.Message ) {}
	public dynamic function onPresence( o : MUCOccupant ) {}
	public dynamic function onSubject( o : String, t : String ) {}
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
	public var me(get_me,null) : MUCOccupant;
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
		c_presence = new PacketCollector( [f_from, new PacketTypeFilter( PacketType.presence )], handlePresence, true );
		c_message = new PacketCollector(  [f_from, new MessageFilter()], handleMessage, true, true );
		//c_message = new PacketCollector(  [f_from, new MessageFilter( MessageType.groupchat )], handleMessage, true );
		
		message = new xmpp.Message( jid, null, null, MessageType.groupchat, null );
		joined = false;
		occupants = new Array();
	}
	
	function get_me() : MUCOccupant {
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
	//public function leave( ?message : String, ?forceEvent : Bool = true ) : xmpp.Presence {
	public function leave( ?message : String ) : xmpp.Presence {
		if( !joined ) return null;
		var p = new xmpp.Presence( null, message, null, unavailable );
		p.to = myjid;
		presence = p;
		stream.sendPacket( p );
	//	if( forceEvent )
	//		destroy();
		//destroy();
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
			#if jabber_debug trace("MUC occupant to kick not found","warn"); #end
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
		case groupchat :
			var from = getOccupantName( m.from );
			if( m.subject != null ) {
				if( m.subject == subject )
					return;
				onSubject( from, subject = m.subject );
				return;
			}
			var occ = getOccupant( from );
			if( occ == null && from != jid && from != nick ) {
				onMessage( null, m );
				return;
			}
			if( occ == null && from == nick  )
				occ = me;
			onMessage( occ, m );
		case error :
			trace( "TODO handle muc error" );
		default :
		}
	}
	
	function handlePresence( p : xmpp.Presence ) {
		if( p.type == error ) {
			onError( new jabber.XMPPError( p ) );
			return;
		}
		var x_user : xmpp.MUCUser = null;
		for( prop in p.properties ) {
			if( prop.nodeName == "x" && prop.get( "xmlns" ) == xmpp.MUCUser.XMLNS ) {
				x_user = xmpp.MUCUser.parse( p.properties[0] );
			}
		}
		if( x_user == null )
			return;
		if( p.from == myjid ) {
			if( p.type == null ) {
				if( !joined ) {
					if( x_user.item != null ) {
						if( x_user.item.role != null ) role = x_user.item.role;
						if( x_user.item.affiliation != null ) affiliation = x_user.item.affiliation;
					}
					// unlock room if required
					if( x_user.item != null && x_user.item.role == Role.moderator &&
						x_user.status != null && x_user.status.code == xmpp.muc.Status.WAITS_FOR_UNLOCK ) {
						var iq = new xmpp.IQ( xmpp.IQType.set, null, jid );
						var q = new xmpp.MUCOwner().toXml();
						q.addChild( new xmpp.DataForm( xmpp.dataform.FormType.submit ).toXml() );
						iq.properties.push( q );
						var self = this;
						stream.sendIQ( iq, function(r:xmpp.IQ) {
							if( r.type == xmpp.IQType.result ) {
								#if jabber_debug trace( "Unlocked MUC room: "+self.room, "info" ); #end
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
					if( x_user.item != null ) {
						role = x_user.item.role;
						affiliation = x_user.item.affiliation;
					}
					presence = p;
					this.onPresence( me );
				}
				return;
			}
			switch( p.type ) {
			case unavailable : 
				joined = false;
				destroy();
				onLeave();
			//case null :
			default :
				trace("##############?");
			}
		} else if( p.from == jid ) {
			trace( "??? process presence from MUC room ???" );
		} else { // process occupant presence
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
		/* 
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
					if( x_user.item != null && x_user.item.role == Role.moderator &&
						x_user.status != null && x_user.status.code == xmpp.muc.Status.WAITS_FOR_UNLOCK ) {
						var iq = new xmpp.IQ( xmpp.IQType.set, null, jid );
						var q = new xmpp.MUCOwner().toXml();
						q.addChild( new xmpp.DataForm( xmpp.dataform.FormType.submit ).toXml() );
						iq.properties.push( q );
						var self = this;
						stream.sendIQ( iq, function(r:xmpp.IQ) {
							if( r.type == xmpp.IQType.result ) {
								#if jabber_debug trace( "Unlocked MUC room: "+self.room, "info" ); #end
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
					if( x_user.item != null ) {
						role = x_user.item.role;
						affiliation = x_user.item.affiliation;
					}
					presence = p;
					this.onPresence( me );
				}
				return;
			}
			switch( p.type ) {
			case unavailable : 
				joined = false;
				destroy();
				onLeave();
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
		*/
	}
	
	function sendMyPresence( priority : Int = 5 ) : xmpp.Presence {
		var x = xmpp.X.create( xmpp.MUC.XMLNS );
		if( password != null ) {
			x.addChild( xmpp.XMLUtil.createElement( "password", this.password ) );
		}

		var p = new xmpp.Presence( null, null, priority );
		p.to = myjid;
		p.properties.push( x );

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
		myjid = room = null;
		presence = null;
		joined = false;
		// TODO remove
		//onLeave();
	}
	
}
