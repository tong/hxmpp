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
import jabber.jingle.transport.RTMPInput;

/**
	Incoming RTMP session handler.
*/
class RTMPResponder extends Session {
	
	public dynamic function onInit() : Void;
	
	/** Transport used */
	public var transport(default,null) : RTMPInput;
	/** Streamhost candidates offered */
	public var candidates(default,null) : Array<xmpp.jingle.TCandidateRTMP>;

	var request : xmpp.IQ;
	var currentTransportIndex : Int;
	var c : PacketCollector;
	
	public function new( stream : jabber.Stream ) {
		super( stream );
	}
	
	public override function terminate( reason : xmpp.jingle.Reason ) {
		transport.close();
		super.terminate( reason );
		//onEnd( this );
	}
	
	/**
	*/
	public function handleRequest( iq : xmpp.IQ ) : Bool {
		var j = xmpp.Jingle.parse( iq.x.toXml() );
		if( j.action != xmpp.jingle.Action.session_initiate )
			return false;
		var content = j.content[0]; //TODO
		candidates = new Array();
		for( sh in content.transport.elements )
			candidates.push( xmpp.jingle.Candidate.parse( sh ) );
		if( candidates.length == 0 )
			return false;
		request = iq;
		entity = iq.from;
		initiator = j.initiator;
		sid = j.sid;
		name = content.name;	
		return true;
	}
	
	/**
	*/
	public function accept() {
		// connect stream
		currentTransportIndex = 0;
		connectTransport();
	}
	
	function connectTransport() {
		transport = RTMPInput.fromCandidate( candidates[currentTransportIndex] );
		transport.__onConnect = handleTransportConnect;
		transport.__onFail = handleTransportConnectFail;
		transport.connect();
	}
	
	function handleTransportConnect() {
		trace( "TRASNPORT CONNECTED "+candidates[currentTransportIndex] );
		transport.__onDisconnect = handleTransportDisconnect;
		// send session result
		stream.sendPacket( new xmpp.IQ( xmpp.IQType.result, request.id, initiator ) );
		// send session accept set
		var iq = new xmpp.IQ( xmpp.IQType.set, null, initiator );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_accept, initiator, sid );
		j.responder = stream.jidstr;
		var content = new xmpp.jingle.Content( initiator, name );
		var xt = Xml.createElement( "transport" );
		xt.set( "xmlns", xmpp.jingle.RTMP.XMLNS );
		var c = new xmpp.jingle.Candidate<xmpp.jingle.TCandidateRTMP>();
		c.attributes = { name : transport.name, host : transport.host, port : transport.port, id : transport.id };
		xt.addChild( c.toXml() );
		content.any.push( xt );
		j.content.push( content );
		iq.x = j;
		stream.sendIQ( iq, handleSessionAccept );
	}
	
	function handleSessionAccept( iq : xmpp.IQ ) {
		trace("handleSessionAccept");
		// collect session packets
		c = new PacketCollector( [cast new xmpp.filter.PacketFromFilter( entity ), cast new xmpp.filter.IQFilter( xmpp.Jingle.XMLNS, xmpp.Jingle.NODENAME, xmpp.IQType.set ) ], handleSessionPacket );
		stream.addCollector( c );
		transport.play();
		onInit();
	}
	
	function handleSessionPacket( iq : xmpp.IQ ) {
		var j = xmpp.Jingle.parse( iq.x.toXml() );
		switch( j.action ) {
		case session_info :
			handleSessionInfoMessage( iq );
		case session_terminate :
			if( transport == null ) {
				return;
			}
			transport.close();
			handleSessionTerminate( iq );
		//
		default :
		}
	}
	
	function handleTransportConnectFail() {
		trace("handleTransportConnectFail");
		currentTransportIndex++;
		if( currentTransportIndex == candidates.length ) {
			onFail( "Cannot connect streamhost" );
			return;
		}
		connectTransport();
	}
	
	function handleTransportDisconnect() {
		trace("TODO RTMP disconnected");
	}
	
}
