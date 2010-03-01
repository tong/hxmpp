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
	
	public static var defaultInterval = 60;
	
	public dynamic function onResponse( jid : String ) : Void;
	public dynamic function onTimeout( jid : String ) : Void;
	public dynamic function onError( e : XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	/** Ping interval ms */
	public var interval : Int; //TODO interval(default,setInterval)
	/** The pinged target entity */
	public var target : String; //public var target : Array<String>; //hm??
	/** Indicates if the ping interval is running */
	public var active(default,null) : Bool;
	
	var timer : Timer;
	var iq : xmpp.IQ;
	
	public function new( stream : Stream, ?target : String, ?interval : Int ) {
		if( interval != null && interval <= 0 )
			throw "Invalid ping interval ("+interval+")";
		this.target = target;
		this.stream = stream;
		this.interval = ( interval != null ) ? interval : defaultInterval;
		active = false;
		iq = new xmpp.IQ( null, null, null, stream.jidstr );
		iq.properties.push( xmpp.Ping.xml );
	}

	/**
		Starts ping packet sending interval.
	*/
	public function run() {
		#if !php
		active = true;
		send( target );
		#end
	}
	
	/**
		Stops the ping interval.
	*/
	public function stop() {
		#if !php
		active = false;
		if( timer != null ) {
			timer.stop();
			timer = null;
		}
		#end
	}
	
	/**
		Sends a ping packet to the given entity, or to the server if the to attribute is omitted.
	*/
	public function send( to : String = null ) {
		#if !php
		iq.to = to;
		var me = this;
		var timeoutHandler = function( c : jabber.stream.PacketCollector ) {
			if( me.active ) {
				me.timer.stop();
				me.timer = null;
			}
			me.onTimeout( to );
		};
		stream.sendIQ( iq, handlePong, false,
					   new jabber.stream.PacketTimeout( [timeoutHandler], interval*1000 ) );
		#end
	}
	
	function handleTimer() {
		#if !php
		timer.stop();
		send( target );
		#end
	}
	
	function handlePong( iq : xmpp.IQ ) {
		#if !php
		switch( iq.type ) {
		case result :
			onResponse( iq.from );
			if( active ) {
				timer = new Timer( interval*1000 );
				timer.run = handleTimer;
			}
		case error :
			onError( new XMPPError( this, iq ) );
		default : //#
		}
		#end
	}

}
