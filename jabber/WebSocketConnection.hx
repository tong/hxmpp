package jabber;

#if js
typedef Socket = WebSocket;
#elseif neko
import neko.net.Socket;
#elseif php
import php.net.Socket;
#elseif cpp
import cpp.net.Socket;
#elseif flash
import flash.net.Socket;
#end

/**
	http://www.w3.org/TR/2009/WD-websockets-20091222/
*/
class WebSocketConnection extends jabber.stream.Connection {
	
	public var url(default,null) : String;
	public var port(default,null) : Int;
		
	var socket : Socket;
	var secure : Bool;
	
	public function new( host : String, port : Int, secure : Bool = false ) {
		super( host );
		this.port = port;
		this.secure = secure;
		url = "ws"+((secure) ? "s":"")+"://"+host+":"+port;
	}
	
	/*
	function getURL() : String {
		return "ws"+((secure) ? "s":"")+"://"+host+":"+port;
	}
	*/
	
	public override function connect() {
		#if js
		socket = new WebSocket( url );
		socket.onopen = handleConnect;
		socket.onclose = handleClose;
		socket.onerror = handleError;
		#end
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		socket.onmessage = handleData;
		return true;
	}
	
	public override function write( t : String ) : Bool {
		#if js
		socket.send( t );
		#end
		return true;
	}
	
	function handleConnect() {
		connected = true;
		__onConnect();
	}
	
	function handleClose() {
		connected = false;
		__onDisconnect();
	}
	
	function handleError() {
		connected = false;
		__onError( "WebSocket error" ); //no error message?
	}
	
	function handleData( m ) {
		#if js
		var d = m.data;
		__onData( haxe.io.Bytes.ofString( d ), 0, d.length );
		#end
	}
	
}
