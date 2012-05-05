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
package jabber.jingle.io;

/**
	Abstract
*/
@:require(js) class WebRTCSDPTransport extends Transport {
	
	/***/
	public var stun_url(default,null) : String;
	
	/** The transmitted SDP (Session description protocol) string */
	public var sdp(default,null) : String;
	
	/** PeerConnection */
	public var connection(default,null) : PeerConnection;
	
	function new( stun_url : String = "STUN stun.l.google.com:19302" ) {
		super();
		this.stun_url = stun_url;
	}
	
	public override function toXml() : Xml {
		var x = xmpp.XMLUtil.createElement( "webrtc", sdp );
		x.set( "xmlns", xmpp.Jingle.XMLNS_WEBRTC );
		return x;
	}
	
	override function connect() {
		trace("CCCCCCCCCCCCCC.....CCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCCC");
		connection = new PeerConnection( stun_url, signalingCallback );
		connection.onconnecting = onSessionConnecting;
    	connection.onopen = onSessionOpened;
    	connection.onaddstream = onRemoteStreamAdded;
		connection.onremovestream = onRemoteStreamRemoved;
	}
	
	function signalingCallback( s : String ) {
		//trace("signalingCallback");
		sdp = s;
		//trace( sdp );
		__onConnect();
	}
	
	function onSessionConnecting() {
		trace("onSessionConnecting");
	}
	
	function onSessionOpened() {
		trace("onSessionOpened");
	}
	
	function onRemoteStreamAdded(e) {
		trace("onRemoteStreamAdded");
	}
	
	function onRemoteStreamRemoved() {
		trace("onRemoteStreamRemoved");
	}

}
