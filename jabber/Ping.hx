package jabber;

//TODO join with Pong ?

/**
	Sends application-level pings over XML streams.
	Such pings can be sent from a client to a server, from one server to another, or end-to-end.
	
	<a href="http://www.xmpp.org/extensions/xep-0199.html">XEP 199 - XMPP Ping</a>
*/
class Ping {
	
	public static var defaultInterval = 3;
	
	public dynamic function onResponse( s : jabber.Stream ) : Void;
	public dynamic function onTimeout( s : jabber.Stream  ) : Void;
	//TODO public dynamic function onError
	
	/** The ping interval in seconds */
	public var interval : Int; //(default,setInterval) TODO!!
	public var stream(default,null) : Stream;
	
	
	public function new( stream : Stream, ?interval : Int ) {
		if( interval != null && interval <= 0 ) throw "Ping interval must be greater than 0";
		this.stream = stream;
		this.interval = if( interval != null ) interval else defaultInterval;
	}
	
	
	/**
		Starts the ping interval.
	*/
	public function start() {
		handleTimer();
	}
	
	/**
		Sends a ping packet to the given entity, or to the server if the to-attribute is omitted.
	*/
	public function send( ?to : String ) {
		var iq = new xmpp.IQ();
		iq.ext = new xmpp.Ping();
		stream.sendIQ( iq, handlePong, false, new jabber.core.PacketTimeout( [handleTimeout], interval*1000 ) );
	}
	
	
	function handleTimer() {
		send();
		util.Delay.run( handleTimer, interval );
	}
	
	function handlePong( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result :
				onResponse( stream );
			case error :
				//TODO
			default :
		}
	}
	
	function handleTimeout( c : jabber.core.TPacketCollector ) {
		onTimeout( stream );
	}
	
}
