package jabber.jingle.io;

import flash.events.NetStatusEvent;
import flash.net.NetConnection;
import flash.net.NetStream;

class RTMPTransport extends Transport {
	
	public var id(default,null) : String;
	public var host(default,null) : String;
	public var port(default,null) : Int;
	public var name(default,null) : String;
	public var ns(default,null) : NetStream;
	
	var nc : NetConnection;
	
	function new( id : String, host : String, port : Int = 1935, ?name : String ) {
		super();
		this.id = id;
		this.host = host;
		this.port = port;
		this.name = name;
	}
	
	public override function connect() {
		nc = new NetConnection();
		nc.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
		try nc.connect( "rtmp://"+host+":"+port ) catch( e : Dynamic ) {
			__onFail();
		}
	}
	
	public override function close() {
		if( ns != null ) ns.close();
		if( nc != null && nc.connected ) nc.close();
	}
	
	public override function toXml() : Xml {
		var x = Xml.createElement( "candidate" );
		x.set( "id", id );
		x.set( "host", host );
		x.set( "port", Std.string( port ) );
		x.set( "name", name );
		return x;
	}
	
	function netStatusHandler( e : NetStatusEvent ) {
		if( StringTools.startsWith( e.info.code, "NetStream.Buffer" ) )
			return;
		switch( e.info.code ) {
		case "NetConnection.Connect.Failed" :
			//connected = false;
			__onFail();
		case "NetConnection.Connect.Closed" :
			//connected = false;
			__onDisconnect();
		case "NetConnection.Connect.Success" :
			ns = new NetStream( nc );
			ns.addEventListener( NetStatusEvent.NET_STATUS, netStatusHandler );
			//connected = true;
			__onConnect();
		}
	}
	
}
