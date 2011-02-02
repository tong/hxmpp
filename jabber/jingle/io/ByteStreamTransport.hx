package jabber.jingle.io;

#if neko
import neko.net.Socket;
#end

class ByteStreamTransport extends Transport {
	
	public var __onComplete : Void->Void;
	
	public var host(default,null) : String;
	public var port(default,null) : Int;
	
	var socket : Socket;
	var bufsize : Int;
	
	public function new( host : String, port : Int, bufsize : Int = 4096 ) {
		super();
		this.host = host;
		this.port = port;
		this.bufsize = bufsize;
	}
	
	public override function toXml() : Xml {
		var x = Xml.createElement( 'candidate' ); // TODO out of spec ..should be 'streamhost'
		x.set( 'host', host );
		x.set( 'port', Std.string( port )  );
		return x;
	}
	
}
