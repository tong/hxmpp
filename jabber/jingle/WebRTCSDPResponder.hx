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

import jabber.jingle.io.WebRTCSDPInput;

//private enum State {}

/**
	Responder for incoming jingle/webrtc session requests
*/
class WebRTCSDPResponder extends SessionResponder<WebRTCSDPInput> {
	
	public function new( stream : jabber.Stream ) {
		super( stream, xmpp.Jingle.XMLNS_WEBRTC );
	}
	
	/*
	override function addTransportCandidate( x : Xml ) {
		trace("addTransportCandidateaddTransportCandidateaddTransportCandidateaddTransportCandidateaddTransportCandidateaddTransportCandidateaddTransportCandidate");
		trace(x);
		//candidates.push( WebRTCInput.ofCandidate( x ) );
	}
	*/
	
	override function handleSessionInfo( x : Array<Xml> ) {
		//trace("---------handleSessionInfo-------");
		var sdp = x[0].firstChild().nodeValue;
		if( transport == null ) {
			transport = new WebRTCSDPInput( sdp );
			transport.__onConnect = handleTransportConnect;
			transport.connect();
		} else {
			//trace("processSignalingMessage");
			transport.connection.processSignalingMessage( sdp );
			sendSessionAccept();
		}
	}
	
	override function handleTransportConnect() {
		var x = xmpp.XMLUtil.createElement( "webrtc", transport.sdp );
		x.set( "xmlns", xmpp.Jingle.XMLNS_WEBRTC );
		sendInfo( x );
	}
	
}
