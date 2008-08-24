package jabber;

#if neko
import neko.net.Host;
import neko.net.Socket;
private typedef Connection = {
	var data : String;
	var buf : haxe.io.Bytes;
	var bufbytes : Int;
}

#elseif flash9 
import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;

#elseif flash
typedef Socket = flash.XMLSocket;

#elseif php
import php.net.Host;
typedef Socket = php.net.Socket;
private typedef Connection = {
	var data : String;
	var buf : haxe.io.Bytes;
	var bufbytes : Int;
}

#end

	// TODO php
	// TODO flash < 9
	// TODO bridge support for all platforms

/**
	neko, flash9, js.
	Basic (socket) connection implementation for jabber streams.
*/
class StreamSocketConnection extends jabber.core.StreamConnection {
	
	#if ( neko || php )
	public static var DEFAULT_SOCKET_TIMEOUT : Int = 1000;
	public static var DEFAULT_BUF_SIZE  : Int = 1024;
	#end
	
	
	public var host(default,null) 	: String;
	public var port(default,null) 	: Int;
	public var socket(default,null) : Socket;
	
	
	public function new( host : String, port : Int ) {
		
		super();
		this.host = host;
		this.port = port;
		
		socket = new Socket();
		
		#if ( js || SOCKET_BRIDGE )
		socket.onConnect = sockConnectHandler;
		socket.onDisconnect = sockDisconnectHandler;
		socket.onData = sockDataHandler;
		
		#elseif neko
		messageHeaderSize = DEFAULT_MESSAGEHEADER_SIZE;
		bufSize = DEFAULT_BUF_SIZE;
		maxBufSize = MAX_BUF_SIZE;
		reading = false;
		
		#elseif flash9
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockDisconnectHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockDisconnectHandler );

		#elseif flash
		throw "Flash<9 not supported right now!";
		
		#elseif php
		//reading = false;
		
		#end
	}
	
	
	override public function connect() {
		
		#if ( neko || php )
//		socket.setTimeout( DEFAULT_SOCKET_TIMEOUT );
		socket.connect( new Host( host ), port );
		connected = true;
		onConnect();
		
		#else
		socket.connect( host, port );

		#end
	}
	
	override public function disconnect() {
		connected = false;
		socket.close();
	}
	
	override public function read( ?activate : Bool = true ) : Bool {
		
		if( activate ) { // add reading listeners
			
			#if SOCKET_BRIDGE
 			socket.onData = sockDataHandler;
			
			#elseif neko
			/*
			while( connected ) {
				readData( { data : null,
							buf : haxe.io.Bytes.alloc( bufSize ),
							bufbytes : 0 } );
			}
			*/
			
			while( connected ) {
				var buf = haxe.io.Bytes.alloc( DEFAULT_BUF_SIZE );
				var l = socket.input.readBytes( buf, 0, buf.length - 0 );
				onData( buf.readString( 0, buf.length ) );
			}
			
			
			#elseif flash9
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			
			#elseif php
			while( connected ) {
				var buf = haxe.io.Bytes.alloc( DEFAULT_BUF_SIZE );
				var l = socket.input.readBytes( buf, 0, buf.length - 0 );
				onData( buf.readString( 0, buf.length ) );
			}
			
			//#else true
			//socket.onData = sockDataHandler;
			 
			#end
			
		} else { // remove reading listeners
			
			#if ( js || SOCKET_BRIDGE )
 			socket.onData = null;
 			
			#elseif ( neko || php )
//			reading = false;
			
			#elseif flash9
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			
			#elseif flash
			//TODO
			
			#end
 		}
		return activate;
	}
	
	override public function send( data : String ) : Bool {
		
		if( !connected ) return false;
		if( data == null || data == "" ) false;
		
		#if ( js || SOCKET_BRIDGE )
		socket.send( data );
		
		#elseif ( neko|| php )
		socket.write( data );
		
		#elseif flash9
		socket.writeUTFBytes( data ); 
		socket.flush();
		
		#elseif flash
		socket.send( data );
		
		#end 
		
		#if XMPP_DEBUG
	//	if( data.length > 1 ) {
			trace( "XMPP>>> " + data + "\n", true );
	//	}
		#end
		
		return true;
	}
	
	
	//#########################
	#if ( js || SOCKET_BRIDGE )
	
	function sockConnectHandler() {
		connected = true;
		onConnect();
	}
	
	function sockDisconnectHandler() {
		connected = false;
	}
	
	function sockDataHandler( data : String ) {
		onData( data );
	}
	
	
	//##########
	#elseif neko
	
	public static var DEFAULT_MESSAGEHEADER_SIZE : Int = 1;
	public static var MAX_BUF_SIZE 				 : Int = (1 << 24);
	
	public var bufSize : Int;
	public var maxBufSize : Int;
	var messageHeaderSize : Int;
	var reading : Bool;
	
	
	function readData( c : Connection ) {
		var buflen = c.buf.length;
		if( c.bufbytes == buflen ) {
			var nsize = buflen * 2;
			if( nsize > MAX_BUF_SIZE ) {
				if( buflen == MAX_BUF_SIZE ) throw "Max buffer size reached";
				nsize = MAX_BUF_SIZE;
			}
			var buf2 = haxe.io.Bytes.alloc( nsize );
			buf2.blit( 0, c.buf, 0, buflen );
			buflen = nsize;
			c.buf = buf2;
		}
		// read available data
		var nbytes = socket.input.readBytes( c.buf, c.bufbytes, buflen - c.bufbytes );
		c.bufbytes += nbytes;
		var pos = 0;
		while( c.bufbytes > 0 ) {
			var nbytes = processClientData( c.data, c.buf, pos, c.bufbytes );
			if( nbytes == 0 ) break;
			pos += nbytes;
			c.bufbytes -= nbytes;
		}
		if( pos > 0 ) c.buf.blit( 0, c.buf, pos, c.bufbytes );
	}

	function processClientData( d : String, buf : haxe.io.Bytes, bufpos : Int, buflen : Int ) {
		onData( buf.readString( bufpos, buflen ) );
		return 0;
	}
	
	
	//############
	#elseif flash9

	function sockConnectHandler( e : Event ) {
		connected = true;
		onConnect();
	}

	function sockDisconnectHandler( e : Event ) {
		connected = false;
		onDisconnect();
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		onData( socket.readUTFBytes( e.bytesLoaded ) );
	}
	
	
	//###########
	#elseif flash
	
	function sockConnectHandler( b : Bool ) {
		connected = b;
		if( b ) onConnect();
	}

	function sockDisconnectHandler() {
		connected = false;
		onDisconnect();
	}
	
	function sockDataHandler( d : String ) {
		onData( d );
	}
	
	function sockXMLDataHandler( d  ) {
		onData( d );
	}
	
	#end
}



#if JABBER_SOCKETBRIDGE

/**
	Socket for socket bridge use.
*/
private class Socket {
	
	static var id_inc : Int = 0;
	
	dynamic public function onConnect() : Void {}
	dynamic public function onDisconnect() : Void {}
	dynamic public function onData( ata : String ) : Void {}
	
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
	public static function init( bridgeName : String, cb : Void->Void, ?delay : Int ) : Void {
		if( !initialized ) {
			if( delay == null || delay > 0 ) delay = DEFAULT_DELAY;
			SocketBridgeConnection.bridgeName = bridgeName;
			sockets = new List<Socket>();
			var ctx = new haxe.remoting.Context();
			ctx.addObject( "SocketBridgeConnection", SocketBridgeConnection );
			cnx = haxe.remoting.ExternalConnection.flashConnect( "default", bridgeName, ctx );
			initialized = true;
			haxe.Timer.delay( cb, delay );
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

#end // JABBER_SOCKETBRIDGE
