/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009-2010 http://www.disktree.net
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

import flash.net.NetConnection;
import flash.net.NetStream;
import flash.events.NetStatusEvent;
import xmpp.IQ;
import xmpp.IQType;

/**
	<a href="http://labs.adobe.com/technologies/stratus/">Adobe stratus</a><br/>
	Outgoing jingle RTMFP session using adobes stratus service.<br/>
	Flash 10+ only.
*/
class RTMFPResponder extends RTMFPSession, implements SessionResponder {
	
	var request : IQ;
	var candidates : Array<xmpp.jingle.TRTMFPCandidate>;
	
	public function new( stream : jabber.Stream, stratusKey : String ) {
		super( stream, stratusKey );
		stream.features.add( xmpp.jingle.RTMFP.XMLNS );
	}
	
	public function handleRequest( iq : IQ ) : Bool {
		var j = xmpp.Jingle.parse( iq.x.toXml() );
		if( j.action != xmpp.jingle.Action.session_initiate )
			return false;
		var content = j.content[0];
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
	
	public function accept( yes : Bool = true ) {
		if( yes ) {
			sessionCollector = createSessionPacketCollector();
			stream.sendData( IQ.createResult( request ).toString() ); // provisionally accept the session
			//transportIndex = 0;
			connectTransport();
		} else {
			terminate( xmpp.jingle.Reason.decline );
		}
	}
	
	function connectTransport() {
		nc = new NetConnection();
		nc.addEventListener( NetStatusEvent.NET_STATUS, netConnectionHandler );
		try nc.connect( RTMFPSession.connectUrl+"/"+stratusKey ) catch( e : Dynamic ) {
			onFail( e );
		}
	}
	
	function netConnectionHandler( e : NetStatusEvent ) {
		#if JABBER_DEBUG trace( e.info.code ); #end
		switch( e.info.code ) {
		case "NetConnection.Connect.Success" :
			ns = new NetStream( nc, candidates[0].id );
			ns.addEventListener( NetStatusEvent.NET_STATUS, netStreamHandler );
			ns.play( candidates[0].publishId ); //TODO
		//	ns.receiveAudio( false );
		//	ns.receiveVideo( false );
			var i : Dynamic = {};
			i.onIncomingCall = function( caller : String ) {
				trace("onIncomingCall: "+caller );
			}
			i.onIm = function( name : String, text : String ) {
				trace("onIm "+name+": "+text );
			}
			ns.client = i;
		case "NetConnection.Connect.Closed" :
			//TODO
		case "NetStream.Connect.Success" :
			//TODO
		case "NetConnection.Connect.Failed" :
			//TODO
		case "NetStream.Connect.Closed" :
			//TODO
			//trace("TODO hangup");
		}
	}
	
	function netStreamHandler( e : NetStatusEvent ) {
		#if JABBER_DEBUG trace( e.info.code ); #end
		switch( e.info.code ) {
		case "NetStream.Play.UnpublishNotify" :
			//
		case "NetStream.Play.Start" :
			trace("AV STREAM STARTED");
			//onConnect();
			//ns.play( "media-caller" );
			onInit();
		}
	}
	
}
