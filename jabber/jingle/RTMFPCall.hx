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
import jabber.JIDUtil;
import jabber.util.Base64;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.jingle.TRTMFPCandidate;

/**
	<a href="http://labs.adobe.com/technologies/stratus/">Adobe stratus</a><br/>
	Outgoing jingle RTMFP session (using adobes stratus service)<br/>
	Flash 10+ only.
*/
class RTMFPCall extends RTMFPSession {
	
	public var publishId(default,null) : String;
	
	var nearId : String;
	var farId : String;
	
	public function new( stream : jabber.Stream, stratusKey : String ) {
		super( stream, stratusKey );
	}
	
	public function init( entity : String, ?publishId : String ) {
		this.entity = entity;
		this.publishId = ( publishId != null ) ? publishId : stream.jid.toString();
		nc = new NetConnection();
		nc.addEventListener( NetStatusEvent.NET_STATUS, netConnectionHandler );
		//active = true;
		try nc.connect( RTMFPSession.connectUrl+"/"+stratusKey ) catch( e : Dynamic ) {
			onFail( "Failed to connect to RTMFP service" );
		}
	}
	
	public override function terminate( ?reason : xmpp.jingle.Reason, ?content : Xml ) {
		if( nc != null && nc.connected ) {
			nc.close();
		}
		super.terminate( reason, content );
	}
	
	function netConnectionHandler( e : NetStatusEvent ) {
		trace( e.info.code );
		switch( e.info.code ) {
		case "NetConnection.Connect.Success" :
			
			onConnect();
			
			nearId = nc.nearID;
			ns = new NetStream( nc, NetStream.DIRECT_CONNECTIONS );
			ns.addEventListener( NetStatusEvent.NET_STATUS, netStreamHandler );
			
			var me = this;
			var o : Dynamic = {};
			o.onPeerConnect = function( caller : NetStream ) : Bool {
				me.farId = caller.farID;
				trace( "Peer connect: "+me.farId );
				return true; 
			}
			ns.client = o;
		
			sid = Base64.random( 16 );
			var iq = new xmpp.IQ( IQType.set, null, entity );
			var j = new xmpp.Jingle( xmpp.jingle.Action.session_initiate, stream.jidstr, sid );
			var content = new xmpp.jingle.Content( JIDUtil.parseBare( stream.jidstr ), "av" );
			//TODO description
			var x = Xml.createElement( "transport" );
			x.set( "xmlns", xmpp.jingle.RTMFP.XMLNS );
			//for( t in transports ) {
			x.addChild( new xmpp.jingle.Candidate<TRTMFPCandidate>( { id : nc.nearID, publishId : publishId } ).toXml() );
			content.any.push( x );
			j.content.push( content );
			iq.x = j;
			sessionCollector = stream.collect( [cast new xmpp.filter.PacketFromFilter( entity ),
						 						cast new xmpp.filter.IQFilter( xmpp.Jingle.XMLNS, "jingle", xmpp.IQType.set ),
												cast new xmpp.filter.JingleFilter( xmpp.jingle.RTMFP.XMLNS, sid )],
						 						handleSessionPacket, true );
			stream.sendIQ( iq, handleSessionInitResponse );
		case "NetConnection.Connect.Closed" :
			//TODO
		case "NetStream.Connect.Success" :
			//TODO 
		case "NetStream.Connect.Closed" :
			//TODO reciever closed stream
		}
	}
	
	function netStreamHandler( e : NetStatusEvent ) {
		#if JABBER_DEBUG trace( e.info.code ); #end
		switch( e.info.code ) {
		case "NetStream.Publish.Start" :
			onInit();
		}
	}
	
	function handleSessionInitResponse( iq : IQ ) {
		switch( iq.type ) {
		case result :
			ns.publish( publishId );
		case error :
			onFail( xmpp.Error.parse( iq.errors[0].toXml() ).condition );
		default : 
		}
	}
	
}
