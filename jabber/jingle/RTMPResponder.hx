package jabber.jingle;

import jabber.jingle.io.RTMPInput;
import xmpp.IQ;

class RTMPResponder extends SessionResponder<RTMPInput> {
	
	public function new( stream : jabber.Stream ) {
		super( stream, "urn:xmpp:jingle:apps:rtmp" );
	}
	
	override function addTransportCandidate( x : Xml ) {
		candidates.push( RTMPInput.ofCandidate( x ) );
	}
	
}
