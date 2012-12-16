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
package jabber;

import jabber.Stream;

/**
 * Request entities for their XSPF playlist.
 */
class XSPF {
	
	public dynamic function onLoad( jid : String, playlist : xspf.Playlist ) {}
	public dynamic function onError( e : jabber.XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	public function request( jid : String ) {
		var iq = new xmpp.IQ( null, null, jid );
		iq.properties.push( xmpp.XSPF.emptyXml() );
		stream.sendIQ( iq, handleResult );
	}
	
	function handleResult( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			if( iq.x == null ) {
				onLoad( iq.from, null );
			} else {
				var x = iq.x.toXml().firstElement();
				var pl : xspf.Playlist = null;
				try {
					pl = xspf.Playlist.parse( x );
				} catch( e : Dynamic ) {
					onError( new XMPPError( iq ) );
					return;
				}
				onLoad( iq.from, pl );
			}
		case error :
			onError( new jabber.XMPPError( iq ) );
		default:
		}
	}
	
}
