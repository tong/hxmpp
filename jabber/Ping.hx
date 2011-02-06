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
	
	public dynamic function onPong( jid : String ) : Void;
	public dynamic function onTimeout( jid : String ) : Void;
	public dynamic function onError( e : XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	public var active(default,null) : Bool;
	public var target : String;
	/** Ping interval in ms */
	public var interval(default,setInterval) : Int;
	
	var iq : xmpp.IQ;
	var timer : Timer;
	var pending : Bool;
	
	public function new( stream : Stream, ?target : String ) {
		this.stream = stream;
		this.target = target;
		active = false;
		iq = new xmpp.IQ( null, null, null, stream.jid.toString() );
		iq.properties.push( xmpp.Ping.xml );
	}
	
	function setInterval( i : Int ) : Int  {
		if( i < 1 )
			return throw new jabber.error.Error( "invalid ping time interval ["+i+"]" );
		return interval = i;
	}
	
	public function run( interval : Int = 30000 ) {
		if( active ) {
			#if JABER_DEBUG trace( "ping is already active", "warn" ); #end
			return;
		}
		this.interval = interval;
		active = true;
		send( target );
	}
	
	public function stop() {
		if( !active ) {
			#if JABER_DEBUG trace( "cannot stop ping, not active", "warn" ); #end
			return;
		}
		timer.stop();
		active = false;
	}
	
	function send( to : String = null ) {
		iq.to = to;
		stream.sendIQ( iq, handlePong );
		pending = true;
		timer = new Timer( interval );
		timer.run = handleTimer;
	}
	
	function handlePong( iq : xmpp.IQ ) {
		timer.stop();
		pending = false;
		onPong( iq.from );
		timer = new Timer( interval );
		timer.run = handleTimer;
	}
	
	function handleTimer() {
		timer.stop();
		timer = null;
		switch( iq.type ) {
		case result :
			if( pending ) {
				onTimeout( target );
			} else send( target );
		case error :
			onError( new XMPPError( iq ) );
		default :
		}
		
	}
	
}
