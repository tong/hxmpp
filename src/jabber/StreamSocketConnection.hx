package jabber;

#if neko
import neko.net.Socket;

#elseif flash9 
import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;

#elseif flash
typedef Socket = flash.XMLSocket;

#elseif php
typedef Socket = php.net.Socket;

#end



#if neko
private typedef Server = {
	var data : String;
	var buf : haxe.io.Bytes;
	var bufpos : Int;
}
#end


/**
	neko, flash9, js.
	
	Basic (socket) connection implementation for jabber streams.
	
	// TODO flash < 9, js
	// TODO neko: threads
	// TODO bridge support for all platforms
*/
class StreamSocketConnection extends jabber.core.StreamConnection {
	
	public var host(default,null) 	: String;
	public var port(default,null) 	: Int;
	public var socket(default,null) : Socket;
	
	
	public function new( host : String, port : Int ) {
		
		super();
		this.host = host;
		this.port = port;
		
		#if ( js || SOCKET_BRIDGE )
		socket = new Socket();
		socket.onConnect = sockConnectHandler;
		socket.onDisconnect = sockDisconnectHandler;
		socket.onData = sockDataHandler;
		
		#elseif neko
		socket = new neko.net.Socket();
//		messageHeaderSize = DEFAULT_MESSAGEHEADER_SIZE;
//		bufSize = DEFAULT_BUF_SIZE;
//		maxBufSize = MAX_BUF_SIZE;
//		reading = false;
		
		#elseif flash9
		socket = new flash.net.Socket(); 
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockDisconnectHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockDisconnectHandler );

		#elseif flash
		throw "Flash<9 not supported right now!";
		//socket = new Socket();
		//socket.onConnect = sockConnectHandler;
		//socket.onClose = sockDisconnectHandler;
		//socket.onData = sockDataHandler;
		//flash.Lib._global.inst = this;
		
		#elseif php
		socket = new php.net.Socket();
		
		#end
	}
	
	
	//TODO return Bool
	override public function connect() {
		
		#if neko
		socket.setTimeout( DEFAULT_SOCKET_TIMEOUT );
		socket.connect( new neko.net.Host( host ), port );
		connected = true;
		onConnect();
		
		#elseif php
	//	socket.setTimeout( 100.0 );
		socket.connect( new php.net.Host( host ), port );
		connected = true;
		onConnect();
		trace("connect " + connected + "  qwe");
		
		#else
	//	#if flash
	//	if( crossdomain != null ) flash.system.Security.loadPolicyFile( crossdomain );
	//	#end
		socket.connect( host, port );

		#end
	}
	
	override public function disconnect() {
		connected = false;
		socket.close();
	}
	
	override public function send( data : String ) : Bool {
		
		if( !connected ) return false;
		
		#if ( js || SOCKET_BRIDGE )
		socket.send( data );
		
		#elseif neko
		socket.write( data );
		
		#elseif flash9
		socket.writeUTFBytes( data ); 
		socket.flush();
		
		#elseif flash
		socket.send( data );
		
		#end 
		
		return true;
	}
	
	override public function read( ?activate : Bool = true ) : Bool {
		
		if( activate ) { // add reading listeners
			
			#if SOCKET_BRIDGE
 			socket.onData = sockDataHandler;
			
			#elseif neko
			/*
	 		reading = activate;
			while( reading ) {
				if( connected ) {
					var s : Server = {
						data : null,
						buf : haxe.io.Bytes.alloc( bufSize ),
						bufpos : 0
					};
					readData( s );
				} else {
					break;
				}
			}
			*/
			
			#elseif flash9
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			
			#elseif php
			trace("reading");
	 		var reading = true;
			while( reading ) {
				trace("---");
				trace( socket.read() );
			}
			
			//#else true
			//socket.onData = sockDataHandler;
			 
			#end
			
		} else { // remove reading listeners
			
			#if ( js || SOCKET_BRIDGE )
 			socket.onData = null;
 			
			#elseif neko
			// TODO check
//			reading = false;
			
			#elseif flash9
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			
			#elseif flash
			socket.onData = null;
			
			#end
 		}
		return activate;
	}
	
	
	//#########################
	#if ( js || SOCKET_BRIDGE )
	
	function sockConnectHandler() {
		trace("sockConnectHandler");
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
	
	public static var DEFAULT_MESSAGEHEADER_SIZE 	: Int = 1;
	public static var DEFAULT_BUF_SIZE 				: Int = 1024;
	public static var MAX_BUF_SIZE 					: Int = (1 << 24);
	public static var DEFAULT_SOCKET_TIMEOUT 		: Int = 1000;
	
	/*
	public var bufSize : Int;
	public var maxBufSize : Int;
	var messageHeaderSize : Int;
	var reading : Bool;
	
	
	//TODO
	function readData( cl : Server ) {
		var buflen = cl.buf.length;
		// eventually double the buffer size
		if( cl.bufpos == buflen ) {
			var nsize = buflen * 2;
			if( nsize > maxBufSize ) {
				if( buflen == maxBufSize )
					throw "Max buffer size reached";
				nsize = maxBufSize;
			}
			var buf2 = haxe.io.Bytes.alloc(nsize);
			buf2.blit(0,cl.buf,0,buflen);
			buflen = nsize;
			cl.buf = buf2;
		}
		// read the available data
		var nbytes = socket.input.readBytes( cl.buf, cl.bufpos , buflen - cl.bufpos );
		cl.bufpos += nbytes;
		// process data
		var pos = 0;
		while( cl.bufpos > 0 ) {
			var nbytes = processClientData( cl.data, cl.buf, pos, cl.bufpos);
			if( nbytes == 0 ) break;
			pos += nbytes;
			cl.bufpos -= nbytes;
		}
		if( pos > 0 ) neko.Lib.copyBytes(cl.buf,0,cl.buf,pos,cl.bufpos);
	}
	
	function processClientData( d : String, buf : String, bufpos : Int, buflen : Int ) {
		//var d = new neko.io.StringInput( buf, bufpos, buflen ).read( buflen );
		onData( d );
		//return { msg : d , bytes : len };
		return d.length; //TODO
	}
*/
	
	//####################################################
	#elseif flash9 //#####################################

	function sockConnectHandler( e : Event ) {
		trace("sockConnectHandler");
		connected = true;
//		socket.addEventListener( Event.CONNECT, sockConnectHandler );
//		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
//		socket.addEventListener( IOErrorEvent.IO_ERROR, sockDisconnectHandler );
//		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockDisconnectHandler );
		onConnect();
	}

	function sockDisconnectHandler( e : Event ) {
		trace("sockDisconnectHandler");
		connected = false;
		onDisconnect();
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		onData( socket.readUTFBytes( e.bytesLoaded ) );
	}
	
	
	
	//####################################################
	#elseif flash //######################################
	
	function sockConnectHandler( b : Bool ) {
		trace("sockConnectHandler");
		connected = b;
		if( b ) onConnect();
	}

	function sockDisconnectHandler() {
		trace("sockDisconnectHandler");
		connected = false;
		onDisconnect();
	}
	
	function sockDataHandler( d : String ) {
		trace("sockDataHandler " );
		onData( d );
	}
	
	function sockXMLDataHandler( d  ) {
		trace("sockXMLDataHandler " + d );
		onData( d );
	}
	
	
	//##################################################
	#elseif php //######################################
	
	/*
	function sockConnectHandler() {
		trace("sockConnectHandler");
	}

	function sockDisconnectHandler() {
		trace("sockDisconnectHandler");
	}
	
	function sockDataHandler() {
		trace("sockDataHandler");
	}
	*/
	
	
	#end
}




#if JABBER_SOCKET_BRIDGE


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


class SocketBridgeConnection {
	
	public static var DEFAULT_DELAY = 500;
	
	public static var cnx(default,null) : haxe.remoting.Connection;
	
	static var initialized = false;
	static var bridgeName : String;
	static var sockets : List<Socket>;
	static var cb : Void->Void;
	
	
	public static function init( bridgeName : String, cb : Void->Void,
								 ?delay : Int ) : Void {
		if( !initialized ) {
			if( delay == null || delay > 0 ) delay = DEFAULT_DELAY;
			SocketBridgeConnection.bridgeName = bridgeName;
			SocketBridgeConnection.cb = cb;
			sockets = new List<Socket>();
			var ctx = new haxe.remoting.Context();
			ctx.addObject( "SocketBridgeConnection", SocketBridgeConnection );
			cnx = haxe.remoting.ExternalConnection.flashConnect( "default", bridgeName, ctx );
			initialized = true;
			haxe.Timer.delay( cb, delay );
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

#end // JABBER_SOCKET_BRIDGE
