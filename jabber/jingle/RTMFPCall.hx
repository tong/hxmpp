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

import jabber.jingle.io.RTMFPOutput;
import jabber.jingle.io.Transport;
import xmpp.IQ;

/**
	Direct RTMFP connection.
*/
class RTMFPCall extends OutgoingSession<RTMFPOutput> {
	
	var pubid : String;
	
	public function new( stream : jabber.Stream, entity : String,
						 contentName : String = "av" ) {
		super( stream, entity, contentName, xmpp.Jingle.XMLNS_RTMFP );
	}
	
	public override function init() {
		candidates = transports.copy();
		connectTransport();
	}
	
	override function handleTransportConnect() {
		sendSessionInit();
	}
	
	override function processSessionPacket( iq : IQ, j : xmpp.Jingle ) {
		switch( j.action ) {
		case session_accept :
			//TODO....check candidates, hmm. no since we use one and only (?)
			transport.publish( pubid );
			onInit();
			stream.sendPacket( IQ.createResult( iq ) );
			
		default :
			trace( "Jingle session packet not handled" );
		}
	}
	
	override function createCandidateXml( t : Transport ) : Xml {
		var x = t.toXml();
		pubid = jabber.util.MD5.encode( Date.now().getTime()+stream.jid.toString()+entity );
		x.set( "pubid", pubid );
		return x;
	}
	
}
