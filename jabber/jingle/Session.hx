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

import jabber.jingle.io.Transport;
import jabber.stream.PacketCollector;
import jabber.util.Base64;
import xmpp.IQ;
import xmpp.IQType;

/**
	Abstract base for incoming or outgoing jingle sessions
*/
class Session<T:Transport> {
	
	public dynamic function onInit() : Void;
	public dynamic function onEnd( reason : xmpp.jingle.Reason ) : Void;
	public dynamic function onFail( e : String ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : jabber.Stream;
	public var entity(default,null) : String;
	/** Used transport */
	public var transport(default,null) : T;
	
	var xmlns : String;
	var sid : String;
	var initiator : String;
	var contentName : String;
	var collector : PacketCollector;
	var candidates : Array<T>;
	var request : IQ;
	var transportCandidateIndex : Int;
	
	function new( stream : jabber.Stream, xmlns : String ) {
		this.stream = stream;
		this.xmlns = xmlns;
		transportCandidateIndex = 0;
	}
	
	/**
	*/
	public function terminate( ?reason : xmpp.jingle.Reason, ?content : Xml ) {
		if( reason == null ) reason = xmpp.jingle.Reason.success;
		var iq = new xmpp.IQ( xmpp.IQType.set, null, entity );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_terminate, initiator, sid );
		j.reason = { type : reason, content : content };
		iq.x = j;
		var me = this;
		stream.sendIQ( iq, function(r:IQ) {
			switch( r.type ) {
			case error :
				me.onError( new jabber.XMPPError( iq ) );
			case result :
				me.onEnd( reason );
			default :
			}
		});
		cleanup();
	}
	
	/**
		Send a informational message.
	*/
	public function sendInfo( ?payload : Xml ) {
		var iq = new IQ( xmpp.IQType.set, null, entity );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_info, initiator, sid );
		if( payload != null ) j.other.push( payload );
		iq.x = j;
		var me = this;
		stream.sendIQ( iq, function(r:IQ) {
			//TODO
			switch( r.type ) {
			case result :
			case error :
				// uiuiui we need to pass the complete packet here to the onError callback
				// .. otherwise the application would never know whats this all about
				//me.onError( new jabber.XMPPError(iq) );
			default :
			}
		} );
	}
	
	function handleSessionPacket( iq : IQ ) {
		var j = xmpp.Jingle.parse( iq.x.toXml() );
		switch( j.action ) {
		case session_terminate :
			onEnd( j.reason.type );
			stream.sendPacket( IQ.createResult( iq ) );
		//case whatelse? :
			cleanup();
		default :
			processSessionPacket( iq, j );
		}
	}
	
	function processSessionPacket( iq : IQ, j : xmpp.Jingle ) {
		//();
		// override me
	}
	
	function addSessionCollector() {
		collector = stream.collect( [cast new xmpp.filter.PacketFromFilter( entity ),
									 cast new xmpp.filter.JingleFilter( xmlns, sid )],
						 			 handleSessionPacket, true );
	}
	
	function connectTransport() {
		transport = candidates[transportCandidateIndex];
		transport.__onConnect = handleTransportConnect;
		transport.__onFail = handleTransportFail;
		transport.connect();
	}
	
	function handleTransportConnect() {
	}
	
	/*
	function handleTransportDisconnect() {
	}
	*/
	
	function handleTransportFail( e : String ) {
		if( ++transportCandidateIndex == candidates.length ) {
			onFail( e );
			cleanup();
		} else connectTransport(); // try next
	}
	
	function cleanup() {
		if( transport != null ) transport.close();
		stream.removeCollector( collector );
		collector = null;
	}
	
}
