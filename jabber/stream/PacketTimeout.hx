package jabber.stream;

import haxe.Timer;
#if neko
typedef Timer = util.Timer;
#end

/**
*/
class PacketTimeout extends event.Dispatcher<PacketCollector> {
	
	/** Default packet timeout ms */
	public static var defaultTimeout = 5000;
	
	public var time(default,setTime) : Int;
	public var collector : PacketCollector;
	
	var timer : Timer;
	
	public function new( handlers : Array<PacketCollector->Void>, ?time : Null<Int> = 0 ) {
		super();
		#if (php&&JABBER_DEBUG)
		trace( "PHP does NOT support PacketTimouts", "warn" );
		#else
		if( handlers != null ) {
			for( h in handlers )
				addHandler( h );
		}
		setTime( time );
		#end
	}
	
	function setTime( t : Int ) : Int  {
		#if !php
		if( t == 0 ) t = defaultTimeout;
		time = t;
		if( timer != null ) {
			timer.stop();
			startTimer();
		}
		#end
		return time;
	}
	
	/**
		Start timeout.
	*/
	public function start( ?t : Int ) {
		#if !php
		if( timer != null ) timer.stop();
		if( t != null ) setTime( t );
		startTimer();
		#end
	}
	
	/**
		Stop reporting timeout to handlers.
	*/
	public function stop() {
		#if !php
		if( timer != null ) {
			timer.stop();
			timer = null;
		}
		#end
	}
	
	/**
		Force to report timeout and stop.
	*/
	public function forceTimeout() {
		dispatchEvent( collector );
		stop();
	}
	
	inline function startTimer() {
		#if !php
		timer = new Timer( time );
		timer.run = handleTimeout;
		#end
	}
	
	function handleTimeout() {
		#if !php
		timer.stop();
		timer = null;
		dispatchEvent( collector );
		#end
	}
	
}
