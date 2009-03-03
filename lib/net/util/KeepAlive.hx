package net.util;

#if neko
import neko.net.Socket;
#elseif flash9
import flash.net.Socket;
#elseif js
typedef Socket = {
	function send( m : String ) : Void;
}
#end


#if !php

/**
	neko, flash9+, (js).
	
	Utility to "keep a socket connection alive".
*/
class KeepAlive {
	
	public static var defaultMessage = " ";
	public static var defaultTime = 60000;
	
	/** Ping interval in seconds. */
	public var time(default,setTime) : Int;
	/** Ping message, usually " ". */
	public var message(default,setMessage) : String;
	public var active : Bool;
	public var socket : Socket;
	
	
	public function new( s : Socket, ?time : Int, ?message = " " ) {
		this.socket = s;
		this.time = ( time != null ) ? time : defaultTime;
		this.message = message;
		active = false;
	}
	
	
	function setTime( t : Int ) : Int {
		if( t < 1 ) throw "Keep alive interval has to be greater than zero";
		Reflect.setField( this, "time", t );
		return this.time;
	}
	
	function setMessage( m : String ) : String {
		if( m == null ) m = defaultMessage;
		Reflect.setField( this, "message", m );
		return m;
	}
	
	
	public function ping( ?msg : String ) {
		if( msg == null ) msg = message;
		#if neko
		socket.write( msg );
		#elseif ( flash9 || flash10 )
		socket.writeUTFBytes( msg ); 
		socket.flush();
		#elseif js
		socket.send( msg );
		#end
	}
	
	public function start() {
		active = true;
		util.Delay.run( interval, time );
	}
	
	public function stop() {
		active = false;
	}
	
	
	function interval() {
		ping( message );
		if( active )
			util.Delay.run( interval, time );
	}

}

#end // !php
