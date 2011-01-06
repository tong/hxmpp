package jabber.jingle;

import jabber.jingle.io.RTMPInput;

class RTMPResponder extends SessionResponder<RTMPInput> {
	
	public function new( stream : jabber.Stream ) {
		super( stream, xmpp.Jingle.XMLNS_RTMP );
	}
	
	override function addTransportCandidate( x : Xml ) {
		candidates.push( RTMPInput.ofCandidate( x ) );
	}
	
}
