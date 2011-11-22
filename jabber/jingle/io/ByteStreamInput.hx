package jabber.jingle.io;

#if neko
import neko.net.Host;
import neko.net.Socket;
import neko.vm.Thread;
#end
import haxe.io.Bytes;
import jabber.util.SOCKS5Output;

class ByteStreamInput extends ByteStreamTransport {

	public var __onProgress : Bytes->Void;
	
	var size : Int;
	
	public function new( host : String, port : Int,
						 size : Int,
						 bufsize : Int = 4096 ) {
		super( host, port );
		this.size = size;
		this.bufsize = bufsize;
	}
	
	public override function connect() {
		#if JABBER_DEBUG
		trace( "Connecting to filetransfer streamhost ["+host+":"+port+"]" );
		#end
		#if (neko||cpp)
		socket = new Socket();
		try {
			socket.connect( new Host( host ), port );
			//new SOCKS5Out().run( socket, digest );
		} catch( e : Dynamic ) {
			__onFail( e );
			return;
		}
		__onConnect();
		
		#end
	}
	
	public function read() {
		#if (neko||cpp)
		var t = Thread.create( t_read );
		t.sendMessage( Thread.current() );
		t.sendMessage( socket.input );
		t.sendMessage( size );
		t.sendMessage( bufsize );
		t.sendMessage( __onProgress );
		t.sendMessage( completeCallback );
		Thread.readMessage( true );
		#end
	}
	
	#if (neko||cpp)
	
	function completeCallback( err : String ) {
		cleanup();
		if( err == null ) {
			__onComplete();
		} else {
			__onFail( err );
		}
	}
	
	function t_read() {
		var main : Thread = Thread.readMessage( true );
		var input : haxe.io.Input = Thread.readMessage( true );
		var size : Int = Thread.readMessage( true );
		var bufsize : Int = Thread.readMessage( true );
		var onProgress : Bytes->Void = Thread.readMessage( true );
		var cb : String->Void = Thread.readMessage( true );
		main.sendMessage( true );
		var pos = 0;
		while( pos < size ) {
			var remain = size-pos;
			var len = ( remain > bufsize ) ? bufsize : remain;
			var bytes : Bytes = null;
			try {
				bytes = input.read( len );
				pos += len;
			} catch( e : Dynamic ) {
				trace(e);
				cb( e );
				return;
			}
			if( onProgress != null ) onProgress( bytes );
		}
		cb( null);
	}
	
	function cleanup() {
		if( socket != null )
			try socket.close() catch( e : Dynamic ) { #if JABBER_DEBUG trace(e); #end }
	}
	
	#end
	
}
