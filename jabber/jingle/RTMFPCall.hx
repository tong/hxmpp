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
	Outgoing (direct) RTMFP connection.
*/
class RTMFPCall extends OutgoingSession<RTMFPOutput> {
	
	public var pubid(default,null) : String;
	
	//var payloads : Array<PayloadType>;
	
	public function new( stream : jabber.Stream, entity : String,
						 contentName : String = 'av' ) {
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
			// TODO this is kinda shitty, just offering one transport here #
			var rid : String = null;
			for( c in j.content[0].other ) {
				rid = c.get("id");
				break;
				/*
				var rid = c.get("id");
				for( t in transports ) {
					if( rid == t.id )
						rids.push(rid);
				}
				*/
			}
			if( rid != transport.id ) {
				terminate( xmpp.jingle.Reason.unsupported_transports );
				cleanup();
				return;
			}
			onInit();
			stream.sendPacket( IQ.createResult( iq ) );
			
		default :
			#if JABBER_DEBUG
			trace( "jingle session packet not handled", "warn" );
			#end
		}
	}
	
	override function createCandidateXml( t : Transport ) : Xml {
		var x = t.toXml();
		pubid = jabber.util.MD5.encode( Date.now().getTime()+stream.jid.toString()+entity );
		x.set( "pubid", pubid );
		return x;
	}
	
}
