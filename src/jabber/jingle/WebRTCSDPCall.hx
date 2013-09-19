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

import webrtc.RTCPeerConnection;
import jabber.jingle.io.WebRTCSDPOutput;
import xmpp.IQ;

//TODO: WebRTCInitializer (?)

/**
	Experimental!
	WebRTC SDP jingle session initiator.
	This implementation does NOT parse the jingle packet but attaches the transmitted SDP information directly to the processSignalingMessage method of the peerconnection.
	
	http://community.igniterealtime.org/docs/DOC-2273
*/
class WebRTCSDPCall extends OutgoingSession<WebRTCSDPOutput> {
	
	/** Callback if the peerconnection of the transport is ready to use */
	public dynamic function onPeerConnection( pc : RTCPeerConnection ) {}
	
	public function new( stream : jabber.Stream, entity : String, contentName : String = "av" ) {
		super( stream, entity, contentName, xmpp.Jingle.XMLNS_WEBRTC );
	}
	
	public override function init() {
		trace( "init webrtc jingle session ..." );
		transport = transports[0]; //TODO
		trace(transport);
		//connectTransport();
		super.init();
		/*
		//var _init = super.init;
		transport.__onConnect = function(){
			trace("TRANSOPORT CONNECTED");
			_init();
		}
		transport.connect();
		*/
	}
	
	override function handleSessionInitResult() {
	
		trace("handleSessionInitResult");
		
		transport.__onConnect = handleTransportConnect;
		transport.__onFail = handleTransportFail;
		transport.connect();
		onPeerConnection( transport.connection );
		
	}
	
	override function handleSessionInfo( x : Array<Xml> ) {
		//TODO check state
		var sdp = x[0].firstChild().nodeValue;
		//TODO
		trace("handleSessionInfo: transport connect" );
		//transport.connection.processSignalingMessage( sdp );
	}
	
	override function processSessionPacket( iq : IQ, j : xmpp.Jingle ) {
		switch( j.action ) {
		case session_accept :
			stream.sendIQ( IQ.createResult(iq) );
			onInit();
		default:
			trace("TODO????????????????");
		}
	}
	
	
	override function handleTransportConnect() {
		trace('handleTransportConnect');
		var x = xmpp.XMLUtil.createElement( "webrtc", transport.sdp );
		x.set( "xmlns", xmpp.Jingle.XMLNS_WEBRTC );
		sendInfo( x );
	}
	
	
}
