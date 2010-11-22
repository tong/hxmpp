package jabber.jingle.io;

import flash.events.NetStatusEvent;
import flash.net.NetStream;

class RTMFPOutput extends RTMFPTransport {
	
	public function new( url : String ) {
		super( url );
	}
	
	public function publish( pubid : String ) {
		ns.publish( pubid );
	}
	
	public override function toXml() : Xml {
		var x = Xml.createElement( "candidate" );
		//x.set( "name", name );
		x.set( "id", nc.nearID );
		/*
		var r = ~/(rtmfp:\/\/)([A-Z0-9.-]+\.[A-Z][A-Z][A-Z]?)(\/([A-Z0-9\-]+))?/i;
		if( !r.match( url ) ) {
			//TODO
			trace("IIIIIIIIIINVAID RTMFP URL");	
			return null;
		}
		x.set( "url", r.matched(1)+r.matched(2) );
		*/
		x.set( "url", url );
		return x;
	}
	
	override function netConnectionHandler( e : NetStatusEvent ) {
		trace(e.info.code);
		switch( e.info.code ) {
		case "NetConnection.Connect.Success" :
			ns = new NetStream( nc, NetStream.DIRECT_CONNECTIONS );
			ns.addEventListener( NetStatusEvent.NET_STATUS, netStreamHandler );
			__onConnect();
		//case "NetStream.Connect.Success" :
			//__onInit();
		}
	}
	
}
