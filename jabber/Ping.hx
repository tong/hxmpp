package jabber;

import haxe.Timer;
#if neko
typedef Timer = util.Timer;
#end

/**
	flash,js,neko<br>
	Sends application-level pings over XML streams.<br>
	Such pings can be sent from a client to a server, from one server to another, or end-to-end.<br>
	<a href="http://www.xmpp.org/extensions/xep-0199.html">XEP 199 - XMPP Ping</a>
*/
class Ping {
	
	public static var defaultInterval = 2000;
	
	public dynamic function onResponse( entity : String ) : Void;
	public dynamic function onTimeout( entity : String ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	/** Ping interval ms */
	public var interval : Int; //(default,setInterval) TODO
	public var active(default,null) : Bool;
	public var target : String;
	
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
		Stops the ping interval, if running-
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
