package jabber.jingle.io;

import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.NetStream;

class RTMFPTransport extends Transport {
	
	public var url(default,null) : String;
	public var ns(default,null) : NetStream;
	
	var nc : NetConnection;
	
	function new( url : String ) {
		super();
		this.url = url;
	}
	
	public override function connect() {
		nc = new NetConnection();
		nc.addEventListener( NetStatusEvent.NET_STATUS, netConnectionHandler );
		try nc.connect( url ) catch( e : Dynamic ) {
			__onFail( "Failed to connect to RTMFP service" );
		}
	}
	
	public override function close() {
		if( ns != null ) ns.close();
		if( nc != null && nc.connected ) nc.close();
	}
	
	function netConnectionHandler( e : NetStatusEvent ) {
		trace(e.info.code);
	}
	
	function netStreamHandler( e : NetStatusEvent ) {
		trace(e.info.code);
	}
	
}
