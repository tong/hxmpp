package jabber.net;

#if jabber_flashsocketbridge

@:keep
@:require(js)
class Socket {
	
	public dynamic function onConnect() {}
	public dynamic function onDisconnect( ?e : String ) {}
	public dynamic function onData( d : String ) {}
	public dynamic function onSecured() {}
	//public dynamic function onError( e : String ) {} //TODO
	
	public var id(default,null) : Int;
	
	public function new( secure : Bool, timeout : Int = 10 ) {
		id = jabber.SocketConnection.createSocket( this, secure, timeout );
		if( id < 0 )
			throw "failed to create socket on flash bridge";
	}
	
	public inline function connect( host : String, port : Int, ?timeout : Int ) {
		jabber.SocketConnection.swf.connect( id, host, port, timeout );
	}
	
	public inline function close() {
		jabber.SocketConnection.swf.disconnect( id );
	}
	
	public inline function send( t : String ) {
		jabber.SocketConnection.swf.send( id, t );
	}
	
	public inline function setSecure() {
		jabber.SocketConnection.swf.setSecure( id );
	}
}

@:keep
@:expose
@:require(js)
class SocketConnection_flashsocketbridge extends jabber.StreamConnection{

	static function __init__() {
		initialized = false;
	}

	/** The id of the html element holding the swf */
	public static var id(default,null) : String;
	
	/** Reference to the swf itself */
	public static var swf(default,null) : Dynamic;
	
	/** Indicates if the socketbridge stuff is initialized */
	public static var initialized(default,null) : Bool;
	
	static var sockets : Map<Int,Socket>;
	
	public static function init( id : String, cb : String->Void, ?delay : Int = 0 ) {
		if( initialized ) {
			#if jabber_debug trace( 'socketbridge already initialized ['+id+']', 'warn' ); #end
			cb( 'socketbridge already initialized ['+id+']' );
			return;
		}
		var _init : Void->Void = function(){
			swf = untyped document.getElementById( id );
			if( swf == null ) {
				#if jabber_debug trace( 'socketbridge swf not found ['+id+']', 'warn' ); #end
				cb( 'socketbridge swf not found ['+id+']' );
				return;
			}
			sockets = new Map();
			initialized = true;
			cb(null);
		}
		if( delay > 0 ) haxe.Timer.delay( _init, delay ) else _init();
	}
	
	public static function createSocket( s : Socket, secure : Bool, timeout : Int ) {
		var id : Int = -1;
		try id = swf.createSocket( secure, false, timeout ) catch( e : Dynamic ) {
			#if jabber_debug trace( e, "error" ); #end
			return -1;
		}
		sockets.set( id, s );
		return id;
	}
	
	static function handleConnect( id : Int ) {
		sockets.get( id ).onConnect();
	}
	
	static function handleDisconnect( id : Int, e : String ) {
		sockets.get( id ).onDisconnect( e );
	}
	
	static function handleData( id : Int, d : String ) {
		sockets.get( id ).onData( d );
	}
	
	static function handleSecure( id : Int ) {
		sockets.get( id ).onSecured();
	}

	public var socket(default,null) : Socket;
	public var port(default,null) : Int;
	public var timeout(default,null) : Int;

	public function new( host : String = "localhost", ?port : Int = 5222, secure = false, timeout : Int = 10 ) {
		super( host, secure, false );
		this.port = port;
		this.timeout = timeout;
	}

	public override function connect() {
		if( !SocketConnection.initialized )
			throw "flashsocketbridge not initialized";
		socket = new Socket( secure, timeout );
		socket.onConnect = sockConnectHandler;
		socket.onDisconnect = sockDisconnectHandler;
		socket.onSecured = sockSecuredHandler;
		socket.connect( host, port, timeout*1000 );
	}

	public override function disconnect() {
		if( !connected )
			return;
		connected = false;
		try socket.close() catch( e : Dynamic ) {
			onDisconnect( e );
		}
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		socket.onData = yes ? sockDataHandler : null;
		return true;
	}
	
	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.send( t );
		return true;
	}
	
	public override function setSecure() {
		socket.setSecure();
	}
	
	function sockConnectHandler() {
		connected = true;
		onConnect();
	}
	
	function sockDisconnectHandler( ?e : String ) {
		connected = false;
		onDisconnect( e );
	}
	
	function sockSecuredHandler() {
		secured = true;
		onSecured( null );
	}
	
	function sockDataHandler( t : String ) {
		onString( t );
	}
	
}

#end
