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

#if php #error
#else

import jabber.util.Timer;

/**
	XEP 199 - XMPP Ping: http://www.xmpp.org/extensions/xep-0199.html

	Sends application-level pings over XML streams.
	Such pings can be sent from a client to a server, from one server to another, or end-to-end.
*/
class Ping {
	
	/** Informational callback that we recieved a pong for the ping */
	public dynamic function onPong( jid : String ) {}
	public dynamic function onTimeout( jid : String ) {}
	public dynamic function onError( e : XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	/** Indicates if this instance is currently sending pings */
	public var active(default,never) : Bool;

	/** JID of the target entity (server if null) */
	public var target : String;
	
	/** Ping interval in ms */
	public var ms(default,set_ms) : Int;
	
	var iq : xmpp.IQ;
	var timer : Timer;
	var pending : Bool;
	
	public function new( stream : Stream, ?target : String, ?ms : Int = 30000 ) {
		this.stream = stream;
		this.target = target;
		this.ms = ms;
	}
	
	function set_ms( i : Int ) : Int  {
		#if jabber_debug
		if( i < 1 )
			throw "invalid ping interval [$i]";
		#end
		return ms = i;
	}
	
	public function run( ?ms : Int ) {
		if( active ) stop();
		if( ms != null ) this.ms = ms;
		iq = new xmpp.IQ( null, null, null, stream.jid.toString() );
		iq.properties.push( xmpp.Ping.xml );
		sendPingIQ( target );
	}
	
	public function stop() {
		timer.stop();
		iq = null;
	}
	
	function sendPingIQ( to : String = null ) {
		iq.to = to;
		iq.id = stream.nextID();
		stream.sendIQ( iq, handlePong );
		pending = true;
		timer = new Timer( ms );
		timer.run = handleTimeout;
	}
	
	function handlePong( iq : xmpp.IQ ) {
		if( Type.enumEq( iq.type, xmpp.IQType.result ) )
			pending = false;
		else {
			//TODO
		}
	}
	
	function handleTimeout() {
		timer.stop();
		timer = null;
		if( pending ) {
			onTimeout( target );
		} else {
			sendPingIQ( target );
		}
	}
	
}

#end
