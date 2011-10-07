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

import jabber.jingle.io.RTMPOutput;
import xmpp.IQ;

/**
	Outgoing RTMP connection.
*/
class RTMPCall extends OutgoingSession<RTMPOutput> {
	
	public function new( stream : jabber.Stream, entity : String, contentName : String = "av" ) {
		super( stream, entity, contentName, xmpp.Jingle.XMLNS_RTMP );
	}
	
	override function processSessionPacket( iq : IQ, j : xmpp.Jingle ) {
		switch( j.action ) {
		case session_accept :
			var content = j.content[0];
			candidates = new Array();
			for( t in transports ) {
				for( e in content.other ) {
					if( e.get( "name" ) == t.name ) {
						candidates.push( t );
						continue;
					}
				}
			}
			if( candidates.length == 0 ) {
				onFail( 'no valid transport candidate selected' );
				return;
			}
			request = iq;
			connectTransport();
		default :
			#if JABBER_DEBUG
			trace( "Jingle session packet ("+j.action+") not handled", "warn" );
			#end
		}
	}
	
	override function handleTransportConnect() {
		transport.__onPublish = handleTransportPublish;
		//onConnect();
		transport.publish();
	}
	
	function handleTransportPublish() {
		onInit();
		stream.sendPacket( IQ.createResult( request ) );
	}
	
}
