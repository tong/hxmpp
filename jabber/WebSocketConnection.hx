package jabber;

#if js

/**
	http://www.w3.org/TR/2009/WD-websockets-20091222/
*/
class WebSocketConnection extends jabber.stream.Connection {
	
	public var url(default,null) : String;
	public var port(default,null) : Int;
	public var socket(default,null) : WebSocket;
	
	public function new( host : String, port : Int, secure : Bool = false ) {
		super( host, secure );
		this.port = port;
		this.secure = secure;
		url = "ws"+(secure?"s":"")+"://"+host+":"+port;
	}
	
	public override function connect() {
		socket = new WebSocket( url );
		socket.onopen = onConnect;
		socket.onclose = onClose;
		socket.onerror = onError;
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		socket.onmessage = yes ? onData : null;
		return true;
	}
	
	public override function write( t : String ) : Bool {
		socket.send( t );
		return true;
	}
	
	function onConnect() {
		connected = true;
		__onConnect();
	}
	
	function onClose() {
		connected = false;
		__onDisconnect();
	}
	
	function onError() {
		connected = false;
		__onError( "WebSocket error" ); // no error message?
	}
	
	function onData( m ) {
		var d = m.data;
		__onData( haxe.io.Bytes.ofString( d ), 0, d.length );
	}
	
}

#end //js
