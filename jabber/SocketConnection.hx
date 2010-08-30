package jabber;

#if (neko||php||cpp)

#if neko
import neko.net.Host;
import neko.net.Socket;
#elseif php
import php.net.Host;
import php.net.Socket;
#elseif cpp
import cpp.net.Host;
import cpp.net.Socket;
#end

class SocketConnection extends jabber.stream.SocketConnection<Socket> {
	
	public var reading(default,null) : Bool;
	
	var buf : haxe.io.Bytes;
	var bufbytes : Int;
	
	public function new( host : String, port : Int = 5222, secure : Bool = #if (neko||cpp||air) false #else true #end,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, secure, bufSize, maxBufSize, timeout );
		reading = false;
		/*
		#if (neko||cpp)
		if( secure ) {
			#if JABBER_DEBUG
			trace( "StartTLS not implemented, use jabber.SecureSocketConnection for legacy TLS instead" );
			#end
			this.secure = false;
		}
		#end
		*/
	}
	
	public override function connect() {
		socket = new Socket();
		buf = haxe.io.Bytes.alloc( bufSize );
		bufbytes = 0;
		socket.connect( new Host( host ), port );
		connected = true;
		__onConnect();
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			reading = true;
			while( reading  && connected )
				readData();
		} else {
			reading = false;
		}
		return true;
	}
	
	public override function setSecure() {
		#if (neko||cpp)
		throw "StartTLS not implemented";
		#elseif php
		try {
			secured = untyped __call__( 'stream_socket_enable_crypto', socket.__s, true, 1 );
		} catch( e : Dynamic ) {
			__onSecured( e );
			return;
		}
		__onSecured( null );
		#end
	}
	
	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.output.writeString( t );
		socket.output.flush();
		return true;
	}
	
	function readData() {
		var buflen = buf.length;
		if( bufbytes == buflen ) {
			var nsize = buflen*2;
			if( nsize > maxBufSize ) {
				nsize = maxBufSize;
				if( buflen == maxBufSize  )
					throw "Max buffer size reached ("+maxBufSize+")";
			}
			var buf2 = haxe.io.Bytes.alloc( nsize );
			buf2.blit( 0, buf, 0, buflen );
			buflen = nsize;
			buf = buf2;
		}
		var nbytes = 0;
		nbytes = socket.input.readBytes( buf, bufbytes, buflen-bufbytes );
		bufbytes += nbytes;
		var pos = 0;
		while( bufbytes > 0 ) {
			var nbytes = __onData( buf, pos, bufbytes );
			if( nbytes == 0 ) {
				return;
			}
			pos += nbytes;
			bufbytes -= nbytes;
		}
		if( reading && pos > 0 )
			buf = haxe.io.Bytes.alloc( bufSize );
		//buf.blit( 0, buf, pos, bufbytes );
	}
}

#elseif flash

#if TLS
import flash.utils.ByteArray;
import tls.controller.SecureSocket;
import tls.event.SecureSocketEvent;
import tls.valueobject.SecurityOptionsVO;

class SocketConnection extends jabber.stream.SocketConnection<SecureSocket> {
	
	public function new( host : String, port : Int = 5222, secure : Bool = true,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, secure, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		socket = new SecureSocket();
		socket.addEventListener( SecureSocketEvent.ON_CONNECT, sockConnectHandler );
		socket.addEventListener( SecureSocketEvent.ON_SECURE_CHANNEL_ESTABLISHED, secureChannelEstablished );
		socket.addEventListener( SecureSocketEvent.ON_CLOSE, sockDisconnectHandler );
		socket.addEventListener( SecureSocketEvent.ON_ERROR, sockErrorHandler );
		socket.connect( host, port );
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			socket.addEventListener( SecureSocketEvent.ON_PROCESSED_DATA, socketDataHandler );
		} else {
			socket.removeEventListener( SecureSocketEvent.ON_PROCESSED_DATA, socketDataHandler );
		}
		return true;
	}
	
	public override function write( t : String ) : Bool {
		socket.sendString( t );
		return true;
	}
	
	public override function setSecure() {
		socket.startSecureSupport( SecurityOptionsVO.getDefaultOptions( SecurityOptionsVO.SECURITY_TYPE_TLS ) );
	}
	
	function sockConnectHandler( e : SecureSocketEvent ) {
		connected = true;
		__onConnect();
	}
	
	function sockDisconnectHandler( e : SecureSocketEvent ) {
		connected = false;
		__onDisconnect();
	}
	
	function secureChannelEstablished( e : SecureSocketEvent ) {
		secured = true;
		__onSecured( null );
	}
	
	function sockErrorHandler( e : SecureSocketEvent ) {
		connected = false;
		__onError( e.toString() );
	}
	
	function socketDataHandler( e : SecureSocketEvent ) {
		var b = haxe.io.Bytes.ofData( e.rawData );
		if( b.length > maxBufSize )
			throw "Max buffer size reached ("+maxBufSize+")";
		__onData(  b, 0, b.length );
		//if( __onData(  b, 0, b.length ) > 0 )
		//	buf = new ByteArray();
	}
}

#else

import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.ByteArray;

class SocketConnection extends jabber.stream.SocketConnection<Socket> {
	
	var buf : ByteArray;
	
	public function new( host : String, port : Int = 5222, secure : Bool = false,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, false, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		socket = new Socket();
		#if flash10
		socket.timeout = timeout*1000;
		#end
		buf = new ByteArray();
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
		socket.connect( host, port );
	}
	
	public override function disconnect() {
		if( !connected )
			return;
		connected = false;
		try {
			socket.close();
		} catch( e : Dynamic ) {
			trace(e);
			__onError( "Error closing socket" );
			return;
		}
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		} else {
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		}
		return true;
	}
	
	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.writeUTFBytes( t ); 
		socket.flush();
		return true;
	}
	
	function sockConnectHandler( e : Event ) {
		connected = true;
		__onConnect();
	}
	
	function sockDisconnectHandler( e : Event ) {
		connected = false;
		__onDisconnect();
	}
	
	function sockErrorHandler( e : Event ) {
		connected = false;
		__onError( e.type );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		socket.readBytes( buf, buf.length, e.bytesLoaded );
		var b = haxe.io.Bytes.ofData( buf );
		if( b.length > maxBufSize )
			throw "Max buffer size reached ("+maxBufSize+")";
		if( __onData(  b, 0, b.length ) > 0 )
			buf = new ByteArray();
		//socket.flush();
	}
}
#end

#elseif js

#if nodejs

import js.Node;

class SocketConnection extends jabber.stream.SocketConnection<Stream> {
	
	var buf : String;
	
	public function new( host : String, port : Int = 5222, secure : Bool = true,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, secure, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		buf = "";
		socket = Node.net.createConnection( port, host );
		socket.setEncoding( Node.UTF8 );
		socket.addListener( Node.EVENT_STREAM_CONNECT, sockConnectHandler );
		socket.addListener( Node.EVENT_STREAM_END, sockDisconnectHandler );
		socket.addListener( Node.EVENT_STREAM_ERROR, sockErrorHandler );
		socket.addListener( Node.EVENT_STREAM_DATA, sockDataHandler );
	}
	
	public override function setSecure() {
		socket.addListener( Node.EVENT_STREAM_SECURE, sockSecureHandler );
		socket.setSecure();
	}
	
	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.write( t );
		return true;
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( !yes )
			socket.removeListener( Node.EVENT_STREAM_DATA, sockDataHandler );
		return true;
	}
	
	function sockConnectHandler() {
		connected = true;
		__onConnect();
	}
	
	function sockDisconnectHandler() {
		connected = false;
		__onDisconnect();
	}
	
	function sockErrorHandler( e : String ) {
		connected = false;
		__onError( e );
	}
	
	function sockSecureHandler() {
		secured = true;
		__onSecured( null );
	}
	
	function sockDataHandler( t : String ) {
		var s = buf+t;
		if( s.length > maxBufSize )
			throw "Max socket buffer size reached ("+maxBufSize+")";
		var r = __onData( haxe.io.Bytes.ofString( s ), 0, s.length );
		buf = ( r == 0 ) ? s : "";
	}
}

#else // <-nodejs / js-socketbridge->

#if JABBER_SOCKETBRIDGE
class SocketConnection extends jabber.stream.SocketConnection<Socket> {
	
	var buf : String;
	
	public function new( host : String,
						 ?port : Int = #if JABBER_COMPONENT 5275 #else 5222 #end,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, secure, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		buf = "";
		socket = new Socket();
		socket.onConnect = sockConnectHandler;
		socket.onDisconnect = sockDisconnectHandler;
		socket.onError = sockErrorHandler;
		socket.connect( host, port );
	}
	
	public override function disconnect() {
		if( !connected )
			return;
		connected = false;
		try {
			socket.close();
		} catch( e : Dynamic ) {
			trace(e);
			__onError( "Error closing socket" );
			return;
		}
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			socket.onData = sockDataHandler;
		} else {
			socket.onData = null;
		}
		return true;
	}
	
	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.send( t );
		return true;
	}
	
	function sockConnectHandler() {
		connected = true;
		__onConnect();
	}
	
	function sockDisconnectHandler() {
		connected = false;
		__onDisconnect();
	}
	
	function sockErrorHandler( e : String ) {
		connected = false;
		__onError( e );
	}
	
	function sockDataHandler( t : String ) {
		var s = buf+t;
		if( s.length > maxBufSize ) {
			#if JABBER_DEBUG
			trace( "Max socket buffer size reached ("+maxBufSize+")" );
			#end
			throw "Max socket buffer size reached ("+maxBufSize+")";
		}
		var r = __onData( haxe.io.Bytes.ofString( s ), 0, s.length );
		buf = ( r == 0 ) ? s : ""; 
	}
}

class Socket {
	
	public dynamic function onConnect() : Void;
	public dynamic function onDisconnect() : Void;
	public dynamic function onData( d : String ) : Void;
	public dynamic function onError( e : String ) : Void;
	
	public var id(default,null) : Int;
	//var timeout : Int;
	
	public function new() {
		var id : Int = SocketBridgeConnection.createSocket( this );
		if( id < 0 )
			throw "Error creating socket on socket bridge";
		this.id = id;
	}
	
	public function connect( host : String, port : Int ) {
		untyped js.Lib.document.getElementById( SocketBridgeConnection.bridgeId ).connect( id, host, port );
	}
	
	public function close() {
		untyped js.Lib.document.getElementById( SocketBridgeConnection.bridgeId ).disconnect( id );
	}
	
	/*
	public function destroy() {
		var _s = untyped js.Lib.document.getElementById( SocketBridgeConnection.bridgeId ).destroy( id );
	}
	*/
	
	public function send( d : String ) {
		untyped js.Lib.document.getElementById( SocketBridgeConnection.bridgeId ).send( id, d );
	}
	
}

class SocketBridgeConnection {
	
	static function __init__() {
		initialized = false;
	}
	
	public static var defaultDelay = 300;
	public static var bridgeId(default,null) : String;
	public static var initialized(default,null) : Bool;
	
	static var sockets : IntHash<Socket>;
	
	public static function init( id : String ) {
		if( initialized ) {
			trace( "Socketbridge already initialized" );
			return;
		}
		bridgeId = id;
		sockets = new IntHash();
		initialized = true;
	}
	
	public static function initDelayed( id : String, cb : Void->Void, ?delay : Int ) {
		if( initialized ) {
			trace( "Socketbridge already initialized" );
			return;
		}
		if( delay == null || delay <= 0 ) delay = defaultDelay;
		init( id );
		haxe.Timer.delay( cb, delay );
	}
	
	
	public static function createSocket( s : Socket ) {
		var id : Int = -1;
		try {
			id = untyped js.Lib.document.getElementById( bridgeId ).createSocket();
		} catch( e : Dynamic ) {
			return -1;
		}
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
	
	public function destroyAllSockets() {}
	
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
#end //JABBER_SOCKETBRIDGE
#end //js
#end
