/*
 * Copyright (c) disktree.net
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

import xmpp.IQ;

/**
	XEP 199 - XMPP Ping: http://www.xmpp.org/extensions/xep-0199.html
*/
class Ping {
	
	/** Informational callback that we recieved a pong for the ping */
	public dynamic function onPong( jid : String ) {}

	/** */
	public dynamic function onError( e : XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	/** JID of the target entity (server if null) */
	public var jid(default,null) : String;

	/** The address of the pending ping */
	//public var pending(default,null) : String;
	public var pending(get,null) : String;
	
	var iq : IQ;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}

	inline function get_pending() : String return (iq == null) ? null : iq.to;

	public function send( to : String ) {
		iq = new IQ( null, null, null, stream.jid.toString() );
		iq.to = to;
		iq.id = stream.nextId();
		iq.properties.push( xmpp.Ping.createXml() );
		stream.sendIQ( iq, handleResponse );
		pending = to;
	}

	public function abort() {
		if( iq == null )
			return;
		stream.removeIdCollector( iq.id );
	}
	
	function handleResponse( iq : IQ ) {
		this.iq == null;
		switch iq.type {
		case result:
			onPong( iq.from );
		case error:
			onError( new jabber.XMPPError( iq ) );
		default:
		}
	}
	
}
