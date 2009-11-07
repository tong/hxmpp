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

import util.Timer;

/**
	flash,js,neko<br>
	Sends application-level pings over XML streams.<br>
	Such pings can be sent from a client to a server, from one server to another, or end-to-end.<br>
	<a href="http://www.xmpp.org/extensions/xep-0199.html">XEP 199 - XMPP Ping</a>
*/
class Ping {
	
	public static var defaultInterval = 60000;
	
	public dynamic function onResponse( entity : String ) : Void;
	public dynamic function onTimeout( entity : String ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	/** Ping interval ms */
	public var interval : Int;
	/** The pinged target entity */
	public var target : String;
	public var active(default,null) : Bool;
	
	var timer : Timer;
	
	public function new( stream : Stream, ?target : String, ?interval : Int ) {
		if( interval != null && interval <= 0 )
			throw "Ping interval must be greater than 0";
		this.target = target;
		this.stream = stream;
		this.interval = ( interval != null ) ? interval : defaultInterval;
		active = false;
	}

	/**
		Starts the ping interval.
	*/
	public function start() {
		active = true;
		send( target );
	}
	
	/**
		Stops the ping interval.
	*/
	public function stop() {
		active = false;
		if( timer != null ) {
			timer.stop();
			timer = null;
		}
	}
	
	/**
		Sends a ping packet to the given entity, or to the entities server if the to attribute is omitted.
	*/
	public function send( ?to : String ) {
		var iq = new xmpp.IQ( null, null, to );
		iq.x = new xmpp.Ping();
		var me = this;
		var timeoutHandler = function( c : jabber.stream.PacketCollector ) {
			if( me.active ) {
				me.timer.stop();
				me.timer = null;
			}
			me.onTimeout( to );
		};
		stream.sendIQ( iq, handlePong, false, new jabber.stream.PacketTimeout( [timeoutHandler], interval ) );
	}
	
	function handleTimer() {
		timer.stop();
		send( target );
	}
	
	function handlePong( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			onResponse( iq.from );
			if( active ) {
				timer = new Timer( interval );
				timer.run = handleTimer;
			}
		case error :
			onError( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}

}
