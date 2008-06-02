package jabber;

#if neko
import neko.net.Socket;

#else flash9 
import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;

#else flash
typedef Socket = flash.XMLSocket;
#end



#if neko
private typedef Server = {
	var data : String;
	var buf : String;
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
class StreamSocketConnection extends jabber.StreamConnection {
	
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
		
		#else neko
		socket = new neko.net.Socket();
		messageHeaderSize = DEFAULT_MESSAGEHEADER_SIZE;
		bufSize = DEFAULT_BUF_SIZE;
		maxBufSize = MAX_BUF_SIZE;
		reading = false;
		
		#else flash9
		socket = new flash.net.Socket(); 
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockDisconnectHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockDisconnectHandler );

		#else flash
		throw "Flash<9 not supported right now!";
		socket = new Socket();
		//socket.onConnect = sockConnectHandler;
		//socket.onClose = sockDisconnectHandler;
		//socket.onData = sockDataHandler;
		//flash.Lib._global.inst = this;
		
		#end
	}
	
	
	//TODO return Bool
	override public function connect() {
		
	//	#if flash
	//	if( crossdomain != null ) flash.system.Security.loadPolicyFile( crossdomain );
	//	#end
		
		#if ( js || SOCKET_BRIDGE )
		//TODO
		
		#else neko
		socket.setTimeout( DEFAULT_SOCKET_TIMEOUT );
		socket.connect( new neko.net.Host( host ), port );
		connected = true;
		onConnect();
			
		#else true
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
		
		#else neko
		socket.write( data );
		
		#else flash9
		socket.writeUTFBytes( data ); 
		socket.flush();
		
		#else flash
		socket.send( data );
		
		#end 
		
		return true;
	}
	
	override public function read( ?activate : Bool ) : Bool {
		
		if( activate == null ) activate = true;
		
		if( activate ) { // add reading listeners
			
			#if ( js || SOCKET_BRIDGE )
 			socket.onData = sockDataHandler;
			
			#else neko
	 		reading = activate;
			while( reading ) {
				if( connected ) {
					var s : Server = {
						data : null,
						buf : neko.Lib.makeString( bufSize ),
						bufpos : 0
					};
					readData( s );
				} else {
					break;
				}
			}
			
			#else flash9
			socket.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			
			//#else true
			//socket.onData = sockDataHandler;
			 
			#end
			
		} else { // remove reading listeners
			
			#if ( js || SOCKET_BRIDGE )
 			socket.onData = null;
 			
			#else neko
			// TODO check
			reading = false;
			
			#else flash9
			socket.removeEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
			
			#else flash
			socket.onData = null;
			
			#end
 		}
		return activate;
	}
	
	
		
	//####################################################
	#if ( js || SOCKET_BRIDGE ) //########################
	
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
	
	
	//########################################################
	#else neko //#############################################
	
	public static var DEFAULT_MESSAGEHEADER_SIZE 	: Int = 1;
	public static var DEFAULT_BUF_SIZE 				: Int = 1024;
	public static var MAX_BUF_SIZE 					: Int = (1 << 24);
	public static var DEFAULT_SOCKET_TIMEOUT 		: Int = 1000;
	
	
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
			var buf2 = neko.Lib.makeString(nsize);
			neko.Lib.copyBytes(buf2,0,cl.buf,0,buflen);
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
		var d = new neko.io.StringInput( buf, bufpos, buflen ).read( buflen );
		onData( d );
		//return { msg : d , bytes : len };
		return d.length; //TODO
	}


	
	//####################################################
	#else flash9 //#######################################

	function sockConnectHandler( e : Event ) {
		connected = true;
		socket.addEventListener( Event.CONNECT, sockConnectHandler );
		socket.addEventListener( Event.CLOSE, sockDisconnectHandler );
		socket.addEventListener( IOErrorEvent.IO_ERROR, sockDisconnectHandler );
		socket.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockDisconnectHandler );
		onConnect();
	}

	function sockDisconnectHandler( e : Event ) {
		connected = false;
		onDisconnect();
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		onData( socket.readUTFBytes( e.bytesLoaded ) );
	}
	
	
	
	//####################################################
	#else flash //########################################
	
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
	
	#end
}




#if SOCKET_BRIDGE

/**
	TODO haxe.jabber.tool.ISocketBridge
	haxe.remoting connection to socket bridge.
*/
//TODO private
class SocketBridgeConnection {
	
	public static var DEFAULT_CNX_DELAY = 500;
	public static var ID = "hxjabber";
	
	public static var cnx(default,null) : haxe.remoting.Connection;
	
	static var bridgeName : String;
	static var sockets : List<Socket>;
	
	
	static function connectRemoting() {
		cnx = haxe.remoting.Connection.flashConnect( bridgeName );
     	// TODO bridge authentication!!
	}
	
	public static function getInstance() {
		if( _instance == null ) throw "SocketBridgeConnection not initialized";
		return _instance;
	}
	static var _instance : SocketBridgeConnection;
	
	// Inits socket bridge remoting connection.
	public static function init( bridgeName : String, cb : Void->Void, ?delay : Int ) : Void->Void {
		if( _instance == null ) {
			if( delay == null ) delay = DEFAULT_CNX_DELAY;
			SocketBridgeConnection.bridgeName = bridgeName;
			sockets = new List<Socket>();
			_instance = new SocketBridgeConnection();
			haxe.remoting.Connection.bind( ID, _instance );
			haxe.Timer.delayed( connectRemoting, delay )();
		}
		return haxe.Timer.delayed( cb, delay );
	}
	function new() {}
	
	
	public static function createSocket( s : Socket ) : Int {
		var id = cnx.jabber.tool.SocketBridge.createSocket.call( [] );
		SocketBridgeConnection.sockets.add( s );
		return id;
	}
	
	
	static function getSocket( id : Int ) : Socket {
		for( s in sockets ) if( s.id == id ) return s;
		return null;
	}
	
		
	function onSockClose( id : Int ) {
		var s = getSocket( id );
		s.onDisconnect();
	}
	
	function onSocketConnect( id : Int ) {
		var s = getSocket( id );
		s.onConnect();
	}
	
	function onSocketData( id : Int, data : String ) {
		var s = getSocket( id );
		s.onData( data );
	}
}


/**
	Socket for connection to socket bridge.
*/
private class Socket {
	
	static var id_inc : Int = 0;
	
	public function onConnect() : Void {}
	public function onDisconnect() : Void {}
	public function onData( data : String ) : Void {}
	
	public var id : Int;
	
	
	public function new() {
		var id = SocketBridgeConnection.createSocket( this );
		if( id == -1 ) throw "Error creating socket at bridge";
		this.id = id;
	}
	
	
	public function connect( host : String, port : Int ) {
		SocketBridgeConnection.cnx.jabber.tool.SocketBridge.connect.call( [ id, host, port ] );
	
	}
	public function close() {
		SocketBridgeConnection.cnx.jabber.tool.SocketBridge.close.call( [ id ] );
	}
	
	public function send( data : String ) {
		SocketBridgeConnection.cnx.jabber.tool.SocketBridge.send.call( [ id, data ] );
	}
}

#end // SOCKET_BRIDGE
