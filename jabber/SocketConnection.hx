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

/**
*/
class SocketConnection extends jabber.stream.Connection {
	
	#if (neko||php)
	public static var DEFAULT_BUFSIZE = (1<<6); // 64
	public static var MAX_BUFSIZE = (1<<22); // 4194304
	#end
	
	public var socket(default,null) : Socket;
	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var timeout(default,setTimeout) : Int;
	public var secure(default,null) : Bool;
	
	#if (neko||php)
	var reading : Bool;
	var buffer : haxe.io.Bytes;
	var bufbytes : Int;
	#end
	
	public function new( host : String, port : Int,
						 ?secure : Bool = false , ?timeout : Int = 10) {
		
		super();
		this.host = host;
		this.port = port;
		#if (flash10||neko||php)
		this.timeout = timeout;
		this.secure = secure;
		#end
		
		socket = new Socket();
		
		#if flash9
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
	
		#elseif (neko||php)
		buffer = haxe.io.Bytes.alloc( DEFAULT_BUFSIZE );
		bufbytes = 0;
		reading = false;
		
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
		socket.connect( new Host( host ), port #if php, if( secure ) "tls" #end );
		connected = true;
		onConnect();
		#else
		#if flash10
//TODO	socket.timeout = timeout*1000;
		#end
		socket.connect( host, port );
		#end
	}
	
	public override function disconnect() {
		if( !connected ) return;
		#if (neko||php) reading = false; #end
		connected = #if (neko||php) reading = #end false;
		socket.close();
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			#if flash9
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			#elseif (neko||php)
			reading = true;
			while( reading  && connected ) {
				readData();
				processData();
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
	
	public override function write( t : String ) : String {
		if( !connected || t == null || t == "" ) return null;
		//TODO
//		for( i in interceptors )
//			t = i.interceptData( t );
		#if flash9
		socket.writeUTFBytes( t ); 
		socket.flush();
		#elseif (neko||php)
		socket.write( t );
		#elseif JABBER_SOCKETBRIDGE
		socket.send( t );
		#end
		return t;
	}
	
	/* TODO
	public override function writeBytes( t : haxe.io.Bytes ) : haxe.io.Bytes {
	}
	*/


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
		var d = socket.readUTFBytes( e.bytesLoaded );
		onData( haxe.io.Bytes.ofString( d ), 0, d.length );
	}
	
	#elseif (neko||php)
	
	//TODO php
	function readData() {
		var buflen = buffer.length;
		// eventually double the buffer size
		if( bufbytes == buflen ) {
			var nsize = buflen*2;
			if( nsize > MAX_BUFSIZE ) {
				//if( buflen == MAX_BUFSIZE )
				//	throw "Max buffer size reached ("+MAX_BUFSIZE+")";
				trace( "Max buffer size reached ("+MAX_BUFSIZE+")" );
				nsize = MAX_BUFSIZE;
			}
			var buf2 = haxe.io.Bytes.alloc( nsize );
			buf2.blit( 0, buffer, 0, buflen );
			buflen = nsize;
			buffer = buf2;
		}
		var nbytes = socket.input.readBytes( buffer, bufbytes, buflen-bufbytes );
		bufbytes += nbytes;
	}
	
	function processData() {
		trace("processData");
		var pos = 0;
		while( bufbytes > 0 && reading ) {
			var nbytes = onData( buffer, pos, bufbytes );
			if( nbytes == 0 )
				break;
			/*
			if( nbytes == -1 ) {
				reading = false;
				disconnect();
				return;
			}
			*/
			pos += nbytes;
			bufbytes -= nbytes;
		}
		if( reading && pos > 0 )
			buffer.blit( 0, buffer, pos, bufbytes );
	}

	/*
	#elseif php
	
	function readData() {
		var available = buffer.length - bufbytes;
		if( available == 0 ) {
			var newsize = buffer.length * 2;
			if( newsize > MAX_BUFSIZE ) {
				newsize = MAX_BUFSIZE;
				if( buffer.length == MAX_BUFSIZE )
					throw "Max buffer size reached";
			}
			var newbuf = haxe.io.Bytes.alloc(newsize);
			newbuf.blit( 0, buffer, 0, bufbytes );
			buffer = newbuf;
			available = newsize - bufbytes;
		}
		var bytes = socket.input.readBytes( buffer, bufbytes, available );
		//var msg : String = buffer.readString( bufbytes, bytes );
		onData( buffer, bufbytes, available );
	}
	*/
	

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
		//handleData( d );
		onData( haxe.io.Bytes.ofString(d), 0, d.length );
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
		//TODO
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
