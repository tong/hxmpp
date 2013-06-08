package jabber.net;

import sys.net.Host;
import sys.net.Socket;
import haxe.io.Bytes;

class SocketConnection_sys extends SocketConnectionBase_sys {

	public function new( host : String = "localhost",
						 port : Int = #if jabber_component 5275 #else 5222 #end,
						 secure : Bool = #if (neko||cpp||air) false #else true #end,
						 ?bufsize : Int, ?maxbufsize : Int,
						 timeout : Int = 10 ) {
		
		super( host, port, secure, bufsize, maxbufsize, timeout );
		
		#if (sys&&jabber_debug)
		if( secure ) {
			trace( "Start-TLS not implemented" );
			this.secure = false;
		}
		#end
	}

	public override function connect() {
		socket = new Socket();
		buf = Bytes.alloc( bufsize );
		bufpos = 0;
		try socket.connect( new Host( host ), port ) catch( e : Dynamic ) {
			__onDisconnect( e );
			return;
		}
		connected = true;
		__onConnect();
	}

	public override function setSecure() {
		#if php
		try {
			secured = untyped __call__( 'stream_socket_enable_crypto', socket.__s, true, 1 );
		} catch( e : Dynamic ) {
			__onSecured( e );
			return;
		}
		__onSecured( null );
		#else
		throw "Start-TLS not implemented";
		#end
	}

	public override function write( t : String ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		try {
			socket.output.writeString( t );
			socket.output.flush();
		} catch(e:Dynamic) {
			#if jabber_debug
			trace(e);
			#end
		}
		return true;
	}
	
	public override function writeBytes( t : Bytes ) : Bool {
		if( !connected || t == null || t.length == 0 )
			return false;
		socket.output.write( t );
		socket.output.flush();
		return true;
	}

}
