package jabber.jingle.io;

class RTMPOutput extends RTMPTransport {
	
	public var __onPublish : Void->Void;
	
	public function new( id : String, host : String, port : Int = 1935, ?name : String ) {
		super( id, host, port, name );
	}
	
	public function publish( ?record : String = "record.flv" ) {
		ns.publish( record, id );
	}
	
	override function netStatusHandler( e : flash.events.NetStatusEvent ) {
		if( e.info.code == "NetStream.Publish.Start" ) __onPublish();
		else super.netStatusHandler( e );
	}
	
}
