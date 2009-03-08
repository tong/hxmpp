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


#if (neko||php)
private typedef Buffer = {
	var bytes : haxe.io.Bytes;
	var pos : Int;
}
#end


class SocketConnection extends jabber.stream.Connection {
	
	public var socket(default,null) : Socket;
	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var timeout(default,setTimeout) : Int;
	
	#if (neko||php)
	var reading : Bool;
	var buf : Buffer;
	var bufSize : Int;
	var maxBufSize : Int;
	var data : StringBuf;
	#end
	
	
	public function new( host : String, port : Int, ?timeout : Int = 10 ) {
		
		super();
		this.host = host;
		this.port = port;
		#if (flash10||neko||php)
		this.timeout = timeout;
		#end
		
		socket = new Socket();
		
		#if flash9
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
		
		#elseif ( neko || php )
		reading = false;
		bufSize = #if neko 64 #elseif php 1024 #end; //TODO!
		buf = { bytes : haxe.io.Bytes.alloc( bufSize ), pos : 0 };
		maxBufSize = (1 << 16); // 65536
		data = new StringBuf();
		
		#elseif JABBER_SOCKETBRIDGE
		socket.onConnect = sockConnectHandler;
		socket.onDisconnect = sockDisconnectHandler;
		socket.onError = sockErrorHandler;
		
		#end
	}
	
	
	function setTimeout( t : Int ) : Int {
		return timeout = ( t <= 0 ) ? 1 : t;
	}
	
	
	public override function connect() {
		#if (neko||php)
//TODO	socket.setTimeout( timeout );
		socket.connect( new Host( host ), port );
		connected = true;
		onConnect();
		#else
		#if flash10
		socket.timeout = timeout*1000;
		#end
		socket.connect( host, port );
		#end
	}
	
	public override function disconnect() {
		if( !connected ) return;
		connected = false;
		socket.close();
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			#if flash9
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			#elseif (neko||php)
			reading = true;
			while( connected && reading ) {
				readData();
				//processData();
			}
			#elseif JABBER_SOCKETBRIDGE
			socket.onData = sockDataHandler;
			#end
		} else {
			#if flash9
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			#elseif (neko||php)
			reading = false;
			#elseif JABBER_SOCKETBRIDGE
			socket.onData = null;
			#end
		}
		return true;
	}
	
	public override function send( data : String ) : String {
		if( !connected || data == null || data == "" ) return null;
		for( i in interceptors )
			data = i.interceptData( data );
		#if flash9
		socket.writeUTFBytes( data ); 
		socket.flush();
		#elseif (neko||php)
		socket.write( data );
		#elseif JABBER_SOCKETBRIDGE
		socket.send( data );
		#end
		return data;
	}
	

	#if (flash9)

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
		dataHandler( socket.readUTFBytes( e.bytesLoaded ) );
	}
	
	
	#elseif (neko)
	
	function readData() {
		var available = buf.bytes.length - buf.pos;
		if( available == 0 ) {
			var newsize = buf.bytes.length * 2;
			if( newsize > maxBufSize ) {
				newsize = maxBufSize;
				if( buf.bytes.length == maxBufSize )
					throw "Max buffer size reached";
			}
			var newbuf = haxe.io.Bytes.alloc(newsize);
			newbuf.blit( 0, buf.bytes, 0, buf.pos );
			buf.bytes = newbuf;
			available = newsize - buf.pos;
		}
		var bytes = socket.input.readBytes( buf.bytes, buf.pos, available );
		var pos = 0;
		var len = buf.pos + bytes;
		while( len >= 1 ) {
			var m = readClientMessage( pos, len );
			if( m == null )
				break;
			pos += m.bytes;
			len -= m.bytes;
			clientMessage( m.msg );
		}
		if( pos > 0 ) buf.bytes.blit( 0, buf.bytes, pos, len );
		buf.pos = len;
	}
	
	
	function readClientMessage( pos : Int, len : Int ) : { msg : String, bytes : Int } {
		var msg : String = buf.bytes.readString( pos, len );
		return { msg: msg, bytes: len };
	}
	
	function clientMessage( msg : String ) {
		data.add( msg );
		var d = data.toString();
		if( ( d.length % buf.bytes.length ) != 0 ) { //WTF!
			data = new StringBuf();
			dataHandler( d );
		}
	}
	
	
	#elseif php
	
	//TODO !!!!!!!!!
	function readData() {
		
		var available = buf.bytes.length - buf.pos;
		
		if( available == 0 ) {
			var newsize = buf.bytes.length * 2;
			if( newsize > maxBufSize ) {
				newsize = maxBufSize;
				if( buf.bytes.length == maxBufSize )
					throw "Max buffer size reached";
			}
			var newbuf = haxe.io.Bytes.alloc(newsize);
			newbuf.blit( 0, buf.bytes, 0, buf.pos );
			buf.bytes = newbuf;
			available = newsize - buf.pos;
		}
		
		var bytes = socket.input.readBytes( buf.bytes, buf.pos, available );
		
		var msg : String = buf.bytes.readString( buf.pos, bytes );
		dataHandler( msg );
	}


	#elseif JABBER_SOCKETBRIDGE
	
	function sockConnectHandler() {
		connected = true;
		onConnect();
	}
	
	function sockDisconnectHandler() {
		connected = false;
		onDisconnect();
	}
	
	function sockErrorHandler( m : String ) {
		connected = false;
		onError( m );
	}
	
	function sockDataHandler( d : String ) {
		dataHandler( d );
	}
	
	#end
	
}


#if JABBER_SOCKETBRIDGE

/**
	Socket for socket bridge use.
*/
class Socket {
	
	//static var id_inc = 0;
	
	public dynamic function onConnect() : Void;
	public dynamic function onDisconnect() : Void;
	public dynamic function onData( d : String ) : Void;
	public dynamic function onError( e : String ) : Void;
	
	public var id(default,null) : Int;

	public function new() {
		var id : Int = SocketBridgeConnection.createSocket( this );
		if( id < 0 ) throw new error.Exception( "Error creating socket" );
		this.id = id;
	}
	
	public function connect( host : String, port : Int ) {
		untyped js.Lib.document.getElementById( SocketBridgeConnection.bridgeId ).connect( id, host, port );
	}
	
	public function close() {
		
		//SocketBridgeConnection.destroySocket( id );
	}
	
	public function send( d : String ) {
		untyped js.Lib.document.getElementById( SocketBridgeConnection.bridgeId ).send( id, d );
	}
	
}


class SocketBridgeConnection {
	
	//public static var defaultBridgeId = "f9bridge";
	public static var defaultDelay = 500;
	public static var bridgeId(default,null) : String;
	
	static var sockets : IntHash<Socket>;
	static var initialized = false;
	
	
	public static function init( id : String ) {
		_init( id );
	}
	
	public static function initDelayed( id : String, cb : Void->Void, ?delay : Int ) {
		if( delay == null || delay < 0 ) delay = defaultDelay;
		_init( id );
		haxe.Timer.delay( cb, delay );
	}
	
	static function _init( id : String ) {
		if( initialized ) throw "Socketbridge already initialized";
		bridgeId = id;
		sockets = new IntHash();
		initialized = true;
	}
	
	public static function createSocket( s : Socket ) {
		var id : Int = untyped js.Lib.document.getElementById( bridgeId ).createSocket();
		sockets.set( id, s );
		return id;
	}
	
	/*
	public static function destroySocket( id : Int ) {
		var removed = untyped js.Lib.document.getElementById( bridgeId ).destroySocket( id );
		if( removed ) {
			var s =  sockets.get( id );
			sockets.remove( id );
			s = null;
		}
	}
	*/
	
	static function handleConnect( id : Int ) {
		var s = sockets.get( id );
		s.onConnect();
	}
	
	static function handleDisonnect( id : Int ) {
		var s = sockets.get( id );
		s.onDisconnect();
	}
	
	static function handleError( id : Int, e : String ) {
		var s = sockets.get( id );
		s.onError( e );
	}
	
	static function handleData( id : Int, d : String ) {
		var s = sockets.get( id );
		s.onData( d );
	}
	
}

#end // JABBER_SOCKETBRIDGE
