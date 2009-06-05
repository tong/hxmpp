package jabber;

/**
	flash,js(,neko)<br>
	Sends application-level pings over XML streams.
	Such pings can be sent from a client to a server, from one server to another, or end-to-end.<br>
	<a href="http://www.xmpp.org/extensions/xep-0199.html">XEP 199 - XMPP Ping</a>
*/
class Ping {
	
	public static var defaultInterval = 2;
	
	public dynamic function onResponse( s : jabber.Stream, entity : String ) : Void;
	public dynamic function onTimeout( s : jabber.Stream, entity : String ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	/** The ping interval in seconds */
	public var interval : Int; //(default,setInterval) TODO
	/** */
	public var running(default,null) : Bool;
	/** */
	public var target : String;

	public function new( stream : Stream, ?interval : Int ) {
		if( interval != null && interval <= 0 )
			throw "Ping interval must be greater than 0";
		this.stream = stream;
		this.interval = if( interval != null ) interval else defaultInterval;
	}
	
	/**
		Starts the ping interval.
	*/
	public function start( ?target : String ) {
		this.target = target;
		running = true;
		util.Delay.run( handleTimer, interval );
	}
	
	/**
		Stops the ping interval, if running-
	*/
	public function stop() {
		running = false;
	}
	
	/**
		Sends a ping packet to the given entity, or to the server if the to-attribute is omitted.
	*/
	public function send( ?to : String ) {
		var iq = new xmpp.IQ( null, null, to );
		iq.x = new xmpp.Ping();
		stream.sendIQ( iq, handlePong, false, new jabber.stream.PacketTimeout( [handleTimeout], interval*1000 ) );
	}
	
	function handleTimer() {
		if( running ) {
			send( target );
			#if !php
			util.Delay.run( handleTimer, interval );
			#end
		}
	}
	
	function handlePong( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result : onResponse( stream, iq.from );
			case error : onError( new jabber.XMPPError( this, iq ) );
			default : //#
		}
	}
	
	function handleTimeout( c : jabber.stream.TPacketCollector ) {
		onTimeout( stream, c.packet.from );
	}

}
