package jabber.jingle.transport;

#if flash

import flash.events.NetStatusEvent;

/**
	flash9
*/
class RTMPTransport {
	
	public var __onFail : Void->Void;
	public var __onConnect : Void->Void;
	public var __onDisconnect : Void->Void;
	
	public var name(default,null) : String;
	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var id(default,null) : String;
	public var ns(default,null) : flash.net.NetStream;
	public var nc(default,null) : flash.net.NetConnection;
	
	function new( name : String, host : String, port : Int, id : String ) {
		this.name = name;
		this.host = host;
		this.port = port;
		this.id = id;
	}
	
	public function connect() {
		nc = new flash.net.NetConnection();
		nc.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
		nc.connect( "rtmp://"+host+":"+port );
	}
	
	public function close() {
		ns.close();
		nc.close();
	}
	
	//public function ping() {
	
	function netStatusHandler( e : NetStatusEvent ) {
		if( StringTools.startsWith( e.info.code, "NetStream.Buffer" ) )
			return;
		trace(e.info.code);
		switch( e.info.code ) {
		case "NetConnection.Connect.Failed" :
			__onFail();
		case "NetConnection.Connect.Closed" :
			__onDisconnect();
		case "NetConnection.Connect.Success" :
			ns = new flash.net.NetStream( nc );
			ns.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			__onConnect();
		}
	}
	
}

#end // flash
