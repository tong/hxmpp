package jabber.stream;


// TODO TimeoutProcess

class PacketTimeout {
	
	/** Default packet timeout in seconds */
	public static var defaultTimeout = 5;
	
	/** null = no timeout
		0 = default timeout
		value = value timeout
	*/
	public var time(getTime,setTime) : Int;
	
	/** */
	public var handlers : Array<PacketCollector->Void>; //handler : IPacketCollector->Void
	
	/** The packet collector this timeout is working for. */
	public var collector : PacketCollector;
	
	var _time : Int;
	var active : Bool;
	//var current_time : Int;
	
	
	public function new( handlers : Array<PacketCollector->Void>, ?time : Int ) {
		active = false;
		this.handlers = handlers;
		setTime( time ); 
	}
	
	
	function getTime() : Int { return _time; }
	function setTime( t : Null<Int> ) : Null<Int> {
		switch( t ) {
			case null : // no timeout
				_time = 0;
			case 0 : 	// default timeout 
				_time = defaultTimeout;
			default : 	// given timeout
				if( t < 0 ) throw "Invalid packettimeout time: "+t; 
				_time = t; 			     
		}
		if( _time == 0 )
			active = false;
		else
			start( _time );
		return _time;	
	}
	
	
	/**
		Starts timeout.
	*/
	public function start( t : Int ) {
		
	//	if( active ) stop(); // TODO TimeoutProcess
	
		active = true;
		_time = t;
		
		#if !php
		util.Delay.run( timeoutHandler, Std.int( _time ) );
		#end
	}
	
	/**
		Stops reporting timeout to handlers.
	*/
	public function stop() {
		active = false;
	}
	
	/**
		Force to report timeout and stop.
	*/
	public function forceTimeout() {
		reportTimeout();
		active = false;
		//
	}
	
	
	function reportTimeout() {
		for( handle in handlers ) handle( collector );
	}
	
	function timeoutHandler() {
		if( active ) {
			reportTimeout();
			active = false;
		}
	}
	
}


/*
private class TimeoutProcess {
	
	public function new() {
	}
}
*/
