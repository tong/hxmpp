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
package jabber;

import jabber.util.Timer;

/**
	<a href="http://www.xmpp.org/extensions/xep-0199.html">XEP 199 - XMPP Ping</a><br/>
	<p>flash,js,neko</p>
	Sends application-level pings over XML streams.<br/>
	Such pings can be sent from a client to a server, from one server to another, or end-to-end.<br/>
*/
class Ping {
	
	/** Informational callback that we recieved a pong for the ping */
	public dynamic function onPong( jid : String ) : Void;
	public dynamic function onTimeout( jid : String ) : Void;
	public dynamic function onError( e : XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	/** Indicates if this instance is currently sending pings in intervals */
	public var active(default,null) : Bool;
	/** JID of the target entity sending pings to */
	public var target : String;
	/** Ping interval in ms */
	public var ms(default,setInterval) : Int;
	
	var iq : xmpp.IQ;
	var timer : Timer;
	var pending : Bool;
	
	public function new( stream : Stream, ?target : String, ?ms : Int = 30000 ) {
		this.stream = stream;
		this.target = target;
		this.ms = ms;
	}
	
	function setInterval( i : Int ) : Int  {
		if( i < 1 )
			return throw new jabber.error.Error( "invalid ping interval ["+i+"]" );
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
		pending = false;
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
