package jabber.net;

import flash.net.Socket;
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;
import flash.utils.ByteArray;
import haxe.io.Bytes;

class SocketConnection_fl extends SocketConnectionBase_fl {
	
	public function new( host : String = "localhost", port : Int = 5222, secure : Bool = false,
						 ?bufSize : Int, ?maxBufSize : Int,
						 timeout : Int = 10 ) {
		super( host, port, false, bufSize, maxBufSize, timeout );
	}
	
	public override function connect() {
		socket = new Socket();
		socket.timeout = timeout*1000;
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
		try socket.close() catch( e : Dynamic ) {
			__onDisconnect( e );
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
	
	public override function writeBytes( t : Bytes ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.writeBytes( t.getData() ); 
		socket.flush();
		return true;
	}
	
	function sockConnectHandler( e : Event ) {
		connected = true;
		__onConnect();
	}
	
	function sockDisconnectHandler( e : Event ) {
		connected = false;
		__onDisconnect(null);
	}
	
	function sockErrorHandler( e : Event ) {
		connected = false;
		__onDisconnect( e.type );
	}
	
	function sockDataHandler( e : ProgressEvent ) {
		var d = new ByteArray();
		socket.readBytes( d, 0, Std.int( e.bytesLoaded ) );
		__onData( haxe.io.Bytes.ofData( d )  );
		/*
		var d = new ByteArray();
		try socket.readBytes( d, 0, Std.int(e.bytesLoaded) ) catch( e : Dynamic ) {
			#if jabber_debug trace( e, "error" ); #end
			return;
		}
		trace(d.length);
		__onData(  haxe.io.Bytes.ofData( d )  );
		*/
	}

}
