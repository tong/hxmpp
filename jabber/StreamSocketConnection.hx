package jabber;

#if flash9 
import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
#elseif neko
import neko.net.Host;
import neko.net.Socket;
#elseif php
import php.net.Host;
import php.net.Socket;
#end

/*
#if ( neko || php )
private typedef Connection = {
	//var data : String;
	var buf : haxe.io.Bytes;
	var bufpos : Int;
}
#end
*/

// TODO socket handling

//TODO
//class SocketConnection {
class StreamSocketConnection extends jabber.core.StreamConnection {
	
	#if ( neko || php )
	public static var SOCKET_TIMEOUT_DEFAULT = 10;
	public static var BUF_SIZE_DEFAULT = 128;
	//public static var BUF_SIZE_MAX = 1024;
	
	var reading : Bool;
	var buf : haxe.io.Bytes;
	var bufpos : Int;
	var data : String;
	
	#end
	
	public var host(default,null) : String;
	public var port(default,null) : Int;
	
	var socket : Socket;
	
	
	public function new( host : String, port : Int ) {
		
		super();
		this.host = host;
		this.port = port;
		
		socket = new Socket();
		
		#if flash9
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
		
		#elseif ( neko || php )
		reading = false;
	//	bufSize = BUF_SIZE_DEFAULT;
	//	maxBufSize = BUF_SIZE_MAX;
	//	messageHeaderSize = 1;
		
		#elseif ( js || SOCKET_BRIDGE )
		socket.onConnect = sockConnectHandler;
		socket.onDisconnect = sockDisconnectHandler;
		
		#end
	}
	
	
	public override function connect() {
		#if ( neko || php )
		socket.connect( new Host( host ), port );
		connected = true;
//		socket.setTimeout( SOCKET_TIMEOUT_DEFAULT );
		onConnect();
		#else
		socket.connect( host, port );
		#end
	}
	
	public override function disconnect() {
		socket.close();
		connected = false;
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			#if flash9
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			#elseif ( neko || php )
			reading = true;
			//c = { buf : haxe.io.Bytes.alloc( bufSize ), bufpos : 0 };
			buf = haxe.io.Bytes.alloc( BUF_SIZE_DEFAULT );
			bufpos = 0;
			data = "";
			while( connected && reading ) {
				readData();
			}
			#elseif ( js || SOCKET_BRIDGE )
			socket.onData = sockDataHandler;
			#end
		} else {
			#if flash9
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			#elseif ( neko || php )
			reading = false;
			#end
		}
		return yes;
	}
	
	public override function send( data : String ) : Bool {
		if( data == null || data == "" ) return false;
		if( !connected ) return false;
		try {
			for( i in interceptors ) data = i.interceptData( data );
		} catch( e : Dynamic ) {
			trace(e);
		}
		#if ( js || SOCKET_BRIDGE )
		socket.send( data );
		#elseif flash9
		socket.writeUTFBytes( data ); 
		socket.flush();
		#elseif ( neko || php )
		socket.write( data );
		#end
		return true;
	}
	
	
	#if flash9

	function sockConnectHandler( e : Event ) {
		connected = true;
		onConnect();
	}

	function sockDisconnectHandler( e : Event ) {
		connected = false;
		onDisconnect();
	}
	
	function sockErrorHandler( e ) {
		connected = false;
		onError( e );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		var data : String = null;
		try {
			data = socket.readUTFBytes( e.bytesLoaded );
		} catch( e : Dynamic ) {
			//TODO
		}
		dataHandler( data );
	}
	
	#elseif ( neko || php )
	
	// TODO replace by net.ClientSocketManager
	// or think over handling socket at application level.
	function readData() {
		var nbytes = socket.input.readBytes( buf, bufpos, buf.length );
		data += buf.readString( 0, nbytes );
		if( nbytes == BUF_SIZE_DEFAULT ) {
			readData();
		} else {
			dataHandler( data );
			data = "";
		}
	}

	
	#elseif ( js || SOCKET_BRIDGE )
	
	function sockConnectHandler() {
		connected = true;
		onConnect();
	}
	
	function sockDisconnectHandler() {
		connected = false;
		onDisconnect();
	}
	
	function sockErrorHandler() {
		connected = false;
		onError( "Socket error" );
	}
	
	function sockDataHandler( data : String ) {
		dataHandler( data );
	}
	
	#end
	
}


#if ( js || SOCKET_BRIDGE )

/**
	Socket for socket bridge use.
*/
private class Socket {
	
	static var id_inc = 0;
	
	public dynamic function onConnect() : Void {}
	public dynamic function onDisconnect() : Void {}
	public dynamic function onData( ata : String ) : Void {}
	
	public var id(default,null) : Int;
	

	public function new() {
		var id = SocketBridgeConnection.createSocket( this );
		if( id == -1 ) throw "Error creating socket at bridge";
		this.id = id;
	}
	
	
	public function connect( host : String, port : Int ) {
		SocketBridgeConnection.cnx.SocketBridge.connect.call( [ id, host, port ] );
	}
	
	public function close() {
		SocketBridgeConnection.cnx.SocketBridge.close.call( [ id ] );
	}
	
	public function send( data : String ) {
		SocketBridgeConnection.cnx.SocketBridge.send.call( [ id, data ] );
	}
	
}


/**
*/
class SocketBridgeConnection {
	
	public static var DEFAULT_DELAY = 500;
	public static var cnx(default,null) : haxe.remoting.Connection;
	
	static var initialized = false;
	static var bridgeName : String;
	static var sockets : List<Socket>;
	
	
	/**
	*/
	public static function init( bridgeName : String, ?cb : Void->Void, ?delay : Int ) : Void {
		if( !initialized ) {
			if( delay == null || delay > 0 ) delay = DEFAULT_DELAY;
			SocketBridgeConnection.bridgeName = bridgeName;
			sockets = new List<Socket>();
			var ctx = new haxe.remoting.Context();
			ctx.addObject( "SocketBridgeConnection", SocketBridgeConnection );
			cnx = haxe.remoting.ExternalConnection.flashConnect( "default", bridgeName, ctx );
			initialized = true;
			if( cb != null ) haxe.Timer.delay( cb, delay );
		} else {
			trace( "Socketbridge already initialized" );
		}
	}
	
	
	static function getSocket( id : Int ) : Socket {
		for( s in sockets ) if( s.id == id ) return s;
		return null;
	}
	
	
	public static function createSocket( s : Socket ) : Int {
		var id = cnx.SocketBridge.createSocket.call([]);
		SocketBridgeConnection.sockets.add( s );
		return id;
	}
	
	
	static function onSocketConnect( id : Int ) {
		var s = getSocket( id );
		s.onConnect();
	}
	
	static function onSockClose( id : Int ) {
		var s = getSocket( id );
		s.onDisconnect();
	}
	
	static function onSocketData( id : Int, data : String ) {
		var s = getSocket( id );
		s.onData( data );
	}
	
}

#end // ( js || SOCKET_BRIDGE )
