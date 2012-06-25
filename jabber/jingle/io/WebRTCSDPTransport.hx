/*
 * Copyright (c) 2012, tong, disktree.net
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
