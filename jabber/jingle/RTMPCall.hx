package jabber.jingle;

import jabber.jingle.io.RTMPOutput;
import xmpp.IQ;

class RTMPCall extends OutgoingSession<RTMPOutput> {
	
	public function new( stream : jabber.Stream, entity : String, contentName : String = "av" ) {
		super( stream, entity, contentName, "urn:xmpp:jingle:apps:rtmp" );
	}
	
	override function processSessionPacket( iq : IQ, j : xmpp.Jingle ) {
		switch( j.action ) {
		case session_accept :
			var content = j.content[0];
			var i = 0;
			candidates = new Array();
			for( t in transports ) {
				for( e in content.other ) {
					if( e.get( "name" ) == t.name ) {
						candidates.push( t );
						continue;
					}
				}
			}
			if( candidates.length == 0 ) {
				trace("TODO No valid transport candidate selected");
				return;
			}
			request = iq;
			connectTransport();
			
		default :
			//
			trace("Jingle session packet not handled");
		}
	}
	
	override function handleTransportConnect() {
		transport.__onPublish = handleTransportPublish;
		//onConnect();
		transport.publish();
	}
	
	function handleTransportPublish() {
		onInit();
		stream.sendPacket( IQ.createResult( request ) );
	}
	
}
