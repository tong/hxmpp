package net.util;

#if neko
import neko.net.Socket;

#elseif php
import php.net.Socket;

#elseif ( flash9 || flash10 )
import flash.net.Socket;

// TODO
#elseif JABBER_SOCKETBRIDGE
import jabber.SocketConnection;

#end


/**
	neko, php, flash9+.
	
	Utility to "keep a socket connection alive".
	(flash9 sockets automaticly close after 360 sec of inactivity)
*/
class KeepAlive {
	
	public static inline var standardMessage = " ";
	public static var defaultMessage = standardMessage;
	public static var defaultTime = 1;
	
	/**
		Ping interval in seconds.
	*/
	public var time(default,setTime) : Int;
	/**
		Ping message, usually " ".
	*/
	public var message(default,setMessage) : String;
	public var active : Bool;
	public var socket : Socket;
	
	
	public function new( s : Socket, ?time : Int, ?message = " " ) {
		this.socket = s;
		this.time = if( time != null ) time else defaultTime;
		this.message = message;
		active = false;
	}
	
	
	function setTime( t : Int ) : Int {
		if( t < 1 ) throw "Keep alive interval has to be greater than zero";
		Reflect.setField( this, "time", t );
		return this.time;
	}
	
	function setMessage( m : String ) : String {
		if( m == null ) return standardMessage;
		Reflect.setField( this, "message", m );
		return m;
	}
	
	
	public function ping( ?msg : String ) {
		if( msg == null ) msg = message;
		#if ( neko || php )
		socket.write( msg );
		#elseif ( flash9 || flash10 )
		socket.writeUTFBytes( msg ); 
		socket.flush();
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
		if( active ) util.Delay.run( interval, time );//start();
	}
	
}
