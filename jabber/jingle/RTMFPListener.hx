package jabber.jingle;

/**
	Listens for jingle/RTMFP session requests.
*/
class RTMFPListener extends SessionListener<RTMFPResponder> {
	
	public var developerKey(default,null) : String;
	
	public function new( stream : jabber.Stream, handler : RTMFPResponder->Void, developerKey : String ) {
		super( stream, handler );
		this.developerKey = developerKey;
	}
	
	override function getXMLNS() : String {
		return xmpp.jingle.RTMFP.XMLNS;
	}
	
	override function createResponder() : RTMFPResponder {
		return new RTMFPResponder( stream, developerKey );
	}
	
}
