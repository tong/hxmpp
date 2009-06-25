package jabber.jingle.transport;

#if flash

/**
	flash9.
*/
class RTMPInput extends RTMPTransport {
	
	//TODO public var __onData : haxe.io.Bytes->Void;
	
	public function new( name : String, host : String, port : Int, id : String ) {
		super( name, host, port, id );
	}
	
	public function play() {
		ns.play( "#"+id );
	}
	
	public static inline function fromCandidate( c : xmpp.jingle.TCandidateRTMP ) {
		return new RTMPInput( c.name, c.host, c.port, c.id );
	}
	
}

#end // flash
