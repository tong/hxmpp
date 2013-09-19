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
package jabber.jingle;

import jabber.jingle.io.WebRTCSDPInput;

//private enum State {}

/**
	Experimental!
	Responder for incoming jingle/webrtc session requests.
	This implementation does NOT parse the jingle packet but attaches the transmitted SDP information directly to the processSignalingMessage method of the peerconnection.
	
	http://community.igniterealtime.org/docs/DOC-2273
*/
class WebRTCSDPResponder extends SessionResponder<WebRTCSDPInput> {
	
	public function new( stream : jabber.Stream ) {
		super( stream, xmpp.Jingle.XMLNS_WEBRTC );
	}
	
	
	override function addTransportCandidate( x : Xml ) {
		trace("addTransportCandidateaddTransportCandidateaddTransportCandidateaddTransportCandidateaddTransportCandidateaddTransportCandidateaddTransportCandidate");
		trace(x);
		//candidates.push( WebRTCInput.ofCandidate( x ) );
	}
	
	
	override function handleSessionInfo( x : Array<Xml> ) {
		trace("---------handleSessionInfo-------");
		var sdp = x[0].firstChild().nodeValue;
		if( transport == null ) {
			transport = new WebRTCSDPInput( sdp );
			transport.__onConnect = handleTransportConnect;
			transport.connect();
		} else {
			trace("TODO processSignalingMessage");
			//transport.connection.processSignalingMessage( sdp );
			sendSessionAccept();
		}
	}
	
	override function handleTransportConnect() {
		var x = xmpp.XMLUtil.createElement( "webrtc", transport.sdp );
		x.set( "xmlns", xmpp.Jingle.XMLNS_WEBRTC );
		sendInfo( x );
	}
	
}
