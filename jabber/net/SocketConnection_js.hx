package jabber.net;

import js.html.WebSocket;

class SocketConnection_js extends SocketConnectionBase_js {
	
	public var url(default,null) : String;
	public var port(default,null) : Int;
	public var socket(default,null) : WebSocket;
	
	public function new( host : String = "localhost", port : Int = 5222, secure : Bool = false ) {
		
		super( host, secure );
		this.port = port;
		this.secure = secure;
		
		url = 'ws'+(secure?'s':'')+'://$host:$port'; // (unofficial) specs do not support secure websocket connections
	}
	
	public override function connect() {
		socket = new WebSocket( url );
		socket.onopen = onConnect;
		socket.onclose = onClose;
		socket.onerror = onError;
	}
	
	public override function disconnect() {
		socket.close();
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		socket.onmessage = onData;
		//if( yes ) socket.onmessage = onData;
		//socket.onmessage = yes ? onData : null;
		return true;
	}
	
	public override function write( t : String ) : Bool {
		socket.send( t );
		return true;
	}
	
	function onConnect(e) {
		connected = true;
		__onConnect();
	}
	
	function onClose(e) {
		connected = false;
		__onDisconnect(null);
	}
	
	function onError(e) {
		connected = false;
		__onDisconnect( "websocket error" ); // no error message?
	}
	
	function onData( m : Dynamic ) {
		__onString( m.data );
	}
	
	public static inline function isSupported() : Bool {
		return untyped window.WebSocket != null;
	}
}
