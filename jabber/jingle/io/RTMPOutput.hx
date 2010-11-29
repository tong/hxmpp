package jabber.jingle.io;

class RTMPOutput extends RTMPTransport {
	
	public var __onPublish : Void->Void;
	
	public function new( name : String, host : String, port : Int = 1935, id : String ) {
		super( name, host, port, id );
	}
	
	public function publish( ?record : String = "record.flv" ) {
		ns.publish( record, id );
	}
	
	override function netStatusHandler( e : flash.events.NetStatusEvent ) {
		if( e.info.code == "NetStream.Publish.Start" ) __onPublish();
		else super.netStatusHandler( e );
	}
	
}
