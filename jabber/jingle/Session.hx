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

/**
	Jingle session base.
*/
class Session {
	
	public dynamic function onEnd( reason : xmpp.jingle.Reason ) : Void;
	public dynamic function onFail( t : String ) : Void;
	public dynamic function onInfo( t : Xml ) : Void;
	//public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	public var entity(default,null) : String;
	public var initiator(default,null) : String;
	public var name(default,null) : String;
	public var sid(default,null) : String;
	
	function new( stream : jabber.Stream ) {
		this.stream = stream;
	}
	
	/**
	*/
	public function terminate( reason : xmpp.jingle.Reason ) {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, entity );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_terminate, initiator, sid );
		var r = Xml.createElement( "reason" );
		var e = Xml.createElement( Type.enumConstructor( reason ) );
		r.addChild( e );
		j.any.push( r );
		iq.x = j;
		var me = this;
		stream.sendIQ( iq, function(r) {
			switch( r.type ) {
			case result :
				me.onEnd( reason );
			case error :
				trace( iq.errors );
				//me.onFail();
				//onError( new jabber.XMPPError( this, iq ) );
			default : //#
			}	
		} );
	}
	
	/**
		Send a informational message.
	*/
	public function sendInfo( ?payload : Xml ) {
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
	
	function handleSessionInfoMessage( iq : xmpp.IQ ) {
		var payload = iq.x.toXml().firstElement();
		if( payload == null ) { // pong
			stream.sendPacket( xmpp.IQ.createResult( iq ) );
		} else {
			// TODO check if info is supported
			onInfo( payload );
		}
	}
	
	function handleSessionTerminate( iq : xmpp.IQ ) {
		stream.sendPacket( xmpp.IQ.createResult( iq ) );
		var _r : String = null;
		try _r = iq.x.toXml().firstElement().nodeName catch( e : Dynamic ) {}
		onEnd( if( _r != null ) Type.createEnum( xmpp.jingle.Reason, _r ) else null );
	}
	
}
