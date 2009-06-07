package jabber.file.io;

#if neko
import neko.net.Socket;
import neko.vm.Thread;
#elseif cpp
import cpp.net.Socket;
import cpp.vm.Thread;
#end

/**
	neko,cpp.
*/
class ByteStreamOutput {
	
	public var udp(default,null) : Bool;
	
	var socket : Socket;
	var client : Socket;
	var host : String;
	var port : Int;
	
	public function new( host : String, port : Int, ?udp = false ) {
		this.host = host;
		this.port = port;
		this.udp = udp;
	}
	
	public function connect() {
		socket = (udp) ? Socket.newUdpSocket() : new Socket();
		socket.bind( new neko.net.Host( host ), port );
        socket.listen( 1 );
	}
	
	public function write( input : haxe.io.Input ) {
		client = Thread.readMessage( false );
		if( client == null )
			throw "Client not connected";
		client.output.write( input.readAll() );
	}
	
	public function close() {
		if( client != null ) client.close();
		socket.close();
	}
	
	public function wait() {
		var t = Thread.create( t_wait );
		t.sendMessage( Thread.current() );
		t.sendMessage( socket );
	}
	
	function t_wait() {
		var main : Thread = Thread.readMessage ( true );
		var socket : Socket = Thread.readMessage ( true );
		while( true ) {
			var c = socket.accept();
			//trace("CLIENT CONNECTED");
			main.sendMessage( c );
			break;
		}
	}
	
}
