package jabber.jingle;

import jabber.jingle.io.RTMPInput;

class RTMPListener extends SessionListener<RTMPInput,RTMPResponder> {
	
	public function new( stream : jabber.Stream, handler : RTMPResponder->Void ) {
		super( stream, handler, xmpp.Jingle.XMLNS_RTMP );
	}
	
	override function createResponder() : RTMPResponder {
		return new RTMPResponder( stream );
	}
	
}
