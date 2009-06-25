package jabber.jingle.transport;

#if flash

/**
	flash9
*/
class RTMPOutput extends RTMPTransport {
	
	public static var defaultRecord = "record.flv";
	
	public var __onPublish : Void->Void;
	
	public var record : String; //TODO
	
	public function new( name : String, host : String, port : Int, id : String ) {
		super( name, host, port, id );
	}
	
	/**
	*/
	public function publish() {
		if( record == null ) record = defaultRecord;
		trace("PUBLISH "+id );
		ns.publish( record, id );
	}
	
	override function netStatusHandler( e : flash.events.NetStatusEvent ) {
		if( e.info.code == "NetStream.Publish.Start" ) {
			__onPublish();
			return;
		}
		super.netStatusHandler( e );
	}
	
	public static inline function ofCandidate( c : xmpp.jingle.TCandidateRTMP ) : RTMPOutput {
		return new RTMPOutput( c.name, c.host, c.port, c.id );
	}
	
}

#end//flash
