package jabber.tool;

import haxe.remoting.Connection;

#if flash9
import flash.events.Event;
import flash.events.IOErrorEvent;
import flash.events.SecurityErrorEvent;
import flash.events.ProgressEvent;



private class Socket extends flash.net.Socket {
	public var id : Int;
	public function new( id : Int) {
		super();
		this.id = id;
	}
}


/**
	flash9.
	SWF Socket bridge.
*/
class SocketBridge {
	
	static inline var CLIENT = "hxjabber"; // haxe.remoting client name
	
	static var cnx : haxe.remoting.Connection; // TODO cnxs : Hash<haxe.remoting.Connection>;
	static var sockets = new List<Socket>();
	static var s_count = 0;
	
	
	static function main() {
		
		haxe.Firebug.redirectTraces();
		
		cnx = haxe.remoting.Connection.jsConnect( CLIENT );
	}
	
	
//TODO	auth client by name, set CLIENT
//	public static function authenticate( secret : String, ) {
//	}
	
	static function createSocket() {
		var id = s_count++;
		var s = new Socket( id );
		s.addEventListener( Event.CONNECT, sockConnectHandler );
		s.addEventListener( Event.CLOSE, sockDisconnectHandler );
		s.addEventListener( IOErrorEvent.IO_ERROR, sockDisconnectHandler );
		s.addEventListener( SecurityErrorEvent.SECURITY_ERROR, sockDisconnectHandler );
		s.addEventListener( ProgressEvent.SOCKET_DATA, sockDataHandler );
		sockets.add( s );
		return id;
	}
	
	static function connect( id : Int, host : String, port : Int ) : Bool {
		var s = getSocket( id );
		s.connect( host, port );
		return true;
	}
	
	static function close( id : Int) : Bool {
		var s = getSocket( id );
		s.close();
		return true;
	}
	
	static function send( id : Int, data : String ) : Bool {
		var s = getSocket( id );
		s.writeUTFBytes( data ); 
		s.flush();
		return true;
	}
	
	
	static function sockConnectHandler( e : Event ) {
		cnx.onSocketConnect.call( [e.target.id] );
	}

	static function sockDisconnectHandler( e : Event ) {
		trace(e);
		cnx.onSockClose.call( [e.target.id] );
	}
	
	static function sockDataHandler( e : ProgressEvent ) {
		cnx.onSocketData.call( [e.target.id, e.target.readUTFBytes( e.bytesLoaded )] );
	}
	
	
	static function getSocket( id : Int ) : Socket {
		for( s in sockets ) if( s.id == id ) return s;
		return null;
	}
}

#end // flash9
