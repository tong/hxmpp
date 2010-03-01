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
package jabber.jingle;

import jabber.stream.PacketCollector;
import xmpp.IQ;

/**
	Abstract jingle session.
*/
class Session {
	
	public dynamic function onConnect() : Void;
	public dynamic function onInit() : Void;
	public dynamic function onInfo( x : Xml ) : Void;
	public dynamic function onFail( info : String ) : Void;
	public dynamic function onEnd( reason : xmpp.jingle.Reason ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	public var entity(default,null) : String;
	public var initiator(default,null) : String;
	public var name(default,null) : String;
	public var sid(default,null) : String;
	public var active(default,null) : Bool;
	
	var sessionCollector : PacketCollector;
	
	function new( stream : jabber.Stream ) {
		this.stream = stream;
		active = false;
	}
	
	/**
	*/
	public function terminate( ?reason : xmpp.jingle.Reason, ?content : Xml ) {
		//if( !active ) 
		if( reason == null ) reason = xmpp.jingle.Reason.success;
		var iq = new xmpp.IQ( xmpp.IQType.set, null, entity );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_terminate, initiator, sid );
		j.reason = { type : reason, content : content };
		iq.x = j;
		var me = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
			case error :
				// me.onFail();
			case result :
				trace("TERMINATE RESULT");
				me.active = false;
				me.onEnd( reason );
			default :
			}
		} );
		cleanup();
	}
	
	/**
		Send a informational message.
	*/
	public function sendInfo( ?payload : Xml ) {
		//if( !active ) 
		var iq = new xmpp.IQ( xmpp.IQType.set, null, entity );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_info, initiator, sid );
		if( payload != null ) {
			//TODO payload.set( "xmlns", ??? );
			j.any.push( payload );
		}
		iq.x = j;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			//TODO
			switch( r.type ) {
			case result :
			case error :
			default :
			}
		} );
	}
	
	function handleInfoMessage( iq : xmpp.IQ ) {
		var x = iq.x.toXml().firstElement();
		if( x == null ) { // pong
			stream.sendPacket( xmpp.IQ.createResult( iq ) );
		} else {
			// TODO check if info is supported
			onInfo( x );
		}
	}
	
	function handleTerminate( iq : IQ ) {
		stream.sendPacket( xmpp.IQ.createResult( iq ) );
		active = false;
		//TODO
		//var _r : String = null;
		//try _r = iq.x.toXml().firstElement().nodeName catch( e : Dynamic ) {}
		//onEnd( if( _r != null ) Type.createEnum( xmpp.jingle.Reason, _r ) else null );
	}
	
	function cleanup() {
		stream.removeCollector( sessionCollector );
		sessionCollector = null;
		active = false;
	}
	
}
