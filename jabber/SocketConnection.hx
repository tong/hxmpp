package jabber;

#if ( flash9  || flash10 ) 
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


// TODO socket handling
class SocketConnection extends jabber.core.StreamConnectionBase {
	
	#if ( neko || php )
	//public static var SOCKET_TIMEOUT_DEFAULT = 10;
	//public static var BUF_SIZE_DEFAULT = 128;
	//public static var BUF_SIZE_MAX = 1024;
	
	var reading : Bool;
	var buf : haxe.io.Bytes;
	var bufpos : Int;
	var data : StringBuf;
	var bufSize : Int;
	var minBufferSize : Int;
	var maxBufferSize : Int;
	var messageHeaderSize : Int;
	
	#end
	
	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var socket(default,null) : Socket; //TODO
	
	
	public function new( host : String, port : Int ) {
		
		super();
		this.host = host;
		this.port = port;
		
		socket = new Socket();
		
		#if ( flash9 || flash10 )
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockErrorHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockErrorHandler );
		
		#elseif ( neko || php )
		bufSize = 128;
		minBufferSize = 1 << 10; // 1 KB
		maxBufferSize = 1 << 22; // 64 KB
		reading = false;
		buf = haxe.io.Bytes.alloc( bufSize );
		bufpos = 0;
		
		#elseif JABBER_SOCKETBRIDGE
		socket.onConnect = sockConnectHandler;
		socket.onDisconnect = sockDisconnectHandler;
		socket.onError = sockErrorHandler;
		
		#end
	}
	
	
	public override function connect() {
		#if ( neko || php )
		try {
			//TODO
	//		socket.setTimeout( SOCKET_TIMEOUT_DEFAULT );
			socket.connect( new Host( host ), port );
			connected = true;
		} catch( e : Dynamic ) {
			throw new jabber.error.SocketConnectionError( e );
		}
		onConnect();
		#else
		socket.connect( host, port );
		#end
	}
	
	public override function disconnect() : Bool {
		if( !connected ) return false;
		socket.close();
		connected = false;
		return true;
	}
	
	public override function read( ?yes : Bool = true ) : Bool {
		if( yes ) {
			#if ( flash9 || flash10 )
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			
			#elseif ( neko || php )
			reading = true;
			data = new StringBuf();
			while( connected && reading ) {
				readData();
			}
			
			#elseif JABBER_SOCKETBRIDGE
			socket.onData = sockDataHandler;
			
			#end
		} else {
			#if ( flash9  || flash10 )
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
		for( i in interceptors ) {
			data = i.interceptData( data );
		}
		#if JABBER_SOCKETBRIDGE
		socket.send( data );
		#elseif ( flash9 || flash10 )
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
		var d : String = null;
		try {
			d = socket.readUTFBytes( e.bytesLoaded );
		} catch( e : Dynamic ) {
			trace( e );
		}
		dataHandler( d );
	}
	
	#elseif ( neko || php )
	
	function readData() {
		var available = buf.length - bufpos;
		if( available == 0 ) {
			var newsize = buf.length * 2;
			if( newsize > maxBufferSize ) {
				newsize = maxBufferSize;
				if( buf.length == maxBufferSize )
					throw "Max buffer size reached";
			}
			var newbuf = haxe.io.Bytes.alloc(newsize);
			newbuf.blit(0,buf,0,bufpos);
			buf = newbuf;
			available = newsize - bufpos;
		}
		var bytes = socket.input.readBytes(buf,bufpos,available);
		var pos = 0;
		var len = bufpos + bytes;
		while( len >= 1 ) {
			var m = readClientMessage( pos, len );
			if( m == null ) break;
			pos += m.bytes;
			len -= m.bytes;
			clientMessage( m.msg );
		}
		if( pos > 0 ) buf.blit( 0, buf, pos, len );
		bufpos = len;
	}
	
	inline function readClientMessage( pos : Int, len : Int ) : { msg : String, bytes : Int } {
		var cpos = pos;
		while( cpos < ( pos+len ) ) cpos++;
		var msg : String = buf.readString( pos, cpos-pos );
		return { msg: msg, bytes: cpos-pos };
	}
	
	function clientMessage( msg : String ) {
		data.add( msg );
		var d = data.toString();
		if( (d.length % bufSize ) != 0 ) {
			data = new StringBuf();
			dataHandler( d );
		}
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
	
	function sockDataHandler( data : String ) {
		dataHandler( data );
	}
	
	#end
	
}


#if JABBER_SOCKETBRIDGE


/**
	Socket for socket bridge use.
*/
class Socket {
	
	static var id_inc = 0;
	
	public dynamic function onConnect() : Void;
	public dynamic function onDisconnect() : Void;
	public dynamic function onData( d : String ) : Void;
	public dynamic function onError( e : String ) : Void;
	
	public var id(default,null) : Int;

	public function new() {
		var id = SocketBridgeConnection.createSocket( this );
		if( id == -1 ) throw new error.Exception( "Error creating socket at bridge" );
		this.id = id;
	}
	
	public function connect( host : String, port : Int ) {
		untyped js.Lib.document.getElementById( "f9bridge" ).connect( id, host, port );
	}
	
	public function close() {
		//SocketBridgeConnection.cnx.SocketBridge.close.call( [ id ] );
	}
	
	public function send( d : String ) {
		untyped js.Lib.document.getElementById( "f9bridge" ).send( id, d );
	}
	
}


class SocketBridgeConnection {
	
	public static var defaultDelay = 500;
	
	static var bridgeId : String;
	static var initialized = false;
	static var sockets : IntHash<Socket>;
	
	public static function init( id : String, cb : Void->Void, ?delay : Int ) {
		if( initialized ) throw "Socketbridge already initialized";
		bridgeId = id;
		if( delay == null || delay < 0 ) delay = defaultDelay;
		sockets = new IntHash();
		initialized = true;
		haxe.Timer.delay( cb, delay );
	}
	
	public static function createSocket( s : Socket ) {
		var id : Int = untyped js.Lib.document.getElementById( "f9bridge" ).createSocket();
		sockets.set( id, s );
		return id;
	}
	
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
