package jabber.jingle;

import jabber.jingle.transport.RTMPInput;
import xmpp.IQ;

/**
	Incoming jingle-RTMP session handler.
*/
class RTMPResponder extends Session {
	
	//public dynamic function onDeny() : Void;
	
	/** Used transport */
	public var transport(default,null) : RTMPInput;
	
	var candidates : Array<xmpp.jingle.TRTMPCandidate>;
	var request : xmpp.IQ;
	var transportIndex : Int;
	
	public function new( stream : jabber.Stream ) {
		super( stream );
	}
	
	public function handleRequest( iq : IQ ) : Bool {
		var j = xmpp.Jingle.parse( iq.x.toXml() );
		if( j.action != xmpp.jingle.Action.session_initiate )
			return false;
		var content = j.content[0]; //TODO
		candidates = new Array();
		for( sh in content.transport.elements )
			candidates.push( xmpp.jingle.Candidate.parse( sh ) );
		if( candidates.length == 0 )
			return false;
		request = iq;
		entity = iq.from;
		initiator = j.initiator;
		sid = j.sid;
		name = content.name;	
		return true;
	}
	
	public function accept( yes : Bool = true ) {
		if( yes ) {
			// collect jingle session packets
			stream.collect( [cast new xmpp.filter.PacketFromFilter( entity ),
						 	 cast new xmpp.filter.IQFilter( xmpp.Jingle.XMLNS, "jingle", xmpp.IQType.set ),
						 	 cast new xmpp.filter.JingleFilter( xmpp.jingle.RTMP.XMLNS, sid )],
							 handleSessionPacket, true );
			// Provisionally accept the session request
			stream.sendData( IQ.createResult( request ).toString() );
			transportIndex = 0;
			connectTransport();
		} else {
			terminate( xmpp.jingle.Reason.decline );
		}
	}
	
	public override function terminate( ?reason : xmpp.jingle.Reason, ?content : Xml ) {
		super.terminate( reason, content );
		cleanup();
	}
	
	function handleSessionPacket( iq : IQ ) {
		var j = xmpp.Jingle.parse( iq.x.toXml() );
		//if( j.sid != sid ) return;
		switch( j.action ) {
		case session_terminate :
			trace("TODO TERMINATOR2");
			if( transport != null && transport.connected )
				transport.close();
			onEnd( j.reason.type );
		default :
		}
	}
	
	function connectTransport() {
		transport = RTMPInput.ofCandidate( candidates[transportIndex] );
		transport.__onConnect = handleTransportConnect;
		transport.__onFail = handleTransportConnectFail;
		transport.connect();
	}
	
	function handleTransportConnect() {
	//	trace("TRANSPORT ..  connect "+transport );
		transport.__onDisconnect = handleTransportDisconnect;
		// send candidate accept
		var iq = new xmpp.IQ( xmpp.IQType.set, null, initiator );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_accept, initiator, sid );
		j.responder = stream.jidstr;
		var content = new xmpp.jingle.Content( initiator, name );
		var xt = Xml.createElement( "transport" );
		xt.set( "xmlns", xmpp.jingle.RTMP.XMLNS );
		var c = new xmpp.jingle.Candidate<xmpp.jingle.TRTMPCandidate>();
		c.attributes = { name : transport.name, host : transport.host, port : transport.port, id : transport.id };
		xt.addChild( c.toXml() );
		content.any.push( xt );
		j.content.push( content );
		iq.x = j;
		stream.sendIQ( iq, handleSessionAccept );
	}
	
	function handleTransportConnectFail() {
		transportIndex++;
		if( transportIndex == candidates.length ) {
			//cleanup();
			onFail( "Unable to connect to RTMP streamhost" );
		} else {
			transportIndex++;
			connectTransport();
		}
	}
	
	function handleTransportDisconnect() {
		trace("TODO handleTransportDisconnect");
	}
	
	function handleSessionAccept( iq : IQ ) {
		transport.play();
		onInit();
	}
	
	override function cleanup() {
		if( transport != null && transport.connected ) {
			transport.close();
			transport = null;
		}
		super.cleanup();
	}
	
}
