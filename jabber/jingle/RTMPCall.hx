package jabber.jingle;

import jabber.JIDUtil;
import jabber.jingle.transport.RTMPOutput;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.jingle.TRTMPCandidate;

//TODO timeout timers

/**
	<a href="http://xmpp.org/extensions/inbox/jingle-rtmp.html">XEP-XXXX: jingle RTMP.</a><br/>
	Outgoing jingle RTMP session.
*/
class RTMPCall extends Session {
	
	//public dynamic function onPublish() : Void;
	
	/** Assigned RTMP transports */
	public var transports(default,null) : Array<RTMPOutput>; //TODO! TRTMPCandidate (?) 
	/** Used RTMP transport */
	public var transport(default,null) : RTMPOutput;
	/** Record filename*/
	public var record(default,null) : String;
	
	var currentTransports : Array<RTMPOutput>;
	var currentTransportIndex : Int;
	var sessionAcceptIQ : IQ;
	//var contentName : String;

	public function new( stream : jabber.Stream, entity : String,
						 ?record : String ) {
		super( stream );
		this.entity = entity;
		this.record = record;
		transports = new Array();
	}
	
	public function init() {
		if( transports.length == 0 )
			throw "No RTMP transports registered";
		sid = util.Base64.random( 16 );
		var iq = new xmpp.IQ( IQType.set, null, entity );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_initiate, stream.jidstr, sid );
		var content = new xmpp.jingle.Content( JIDUtil.parseBare( stream.jidstr ), "av" );
		var xt = Xml.createElement( "transport" );
		xt.set( "xmlns", xmpp.jingle.RTMP.XMLNS );
		//TODO
		for( t in transports ) {
			xt.addChild( new xmpp.jingle.Candidate<TRTMPCandidate>( { name : t.name, host : t.host, port : t.port, id : t.id } ).toXml() );
		}
		content.any.push( xt );
		j.content.push( content );
		iq.x = j;
		// collect jingle session packets
		sessionCollector = stream.collect( [cast new xmpp.filter.PacketFromFilter( entity ),
						 					cast new xmpp.filter.IQFilter( xmpp.Jingle.XMLNS, "jingle", xmpp.IQType.set ),
											cast new xmpp.filter.JingleFilter( xmpp.jingle.RTMP.XMLNS, sid )],
						 					handleSessionPacket, true );
		stream.sendIQ( iq, handleSessionInitResponse );
	}
	
	public override function terminate( ?reason : xmpp.jingle.Reason, ?content : Xml ) {
		super.terminate( reason, content );
		cleanup();
	}
	
	function handleSessionInitResponse( iq : IQ  ) {
		switch( iq.type ) {
		case result :
			//TODO..
		case error :
			//TODO onFail( );
		default : 
		}
	}
	
	function handleSessionPacket( iq : IQ ) {
		var j = xmpp.Jingle.parse( iq.x.toXml() );
		//TODO check own state
		//..
	//	if( j.sid != sid ) return;
		switch( j.action ) {
		case session_accept :
			if( transport != null ) {
				//TODO return error
				trace("Invalid request, session already active");
				return;
			}
			//trace( "Jingle session accepted ..." );
			var content = j.content[0]; //TODO
			var candidates = new Array<xmpp.jingle.TRTMPCandidate>();
			for( h in content.transport.elements )
				candidates.push( xmpp.jingle.Candidate.parse( h ) );
			currentTransports = new Array<RTMPOutput>();
			for( c in candidates )
				for( t in transports )
					if( t.name == c.name && t.host == c.host && t.port == c.port && t.id == c.id )
						currentTransports.push( t );
			if( currentTransports.length == 0 ) {
				trace("TODO No valid transport selected");
				return;
			}
			sessionAcceptIQ = iq;
			currentTransportIndex = 0;
			connectTransport();
		
		case session_terminate :
			//if( !active
			if( transport != null ) transport.close();
			onEnd( j.reason.type );
		
		case session_info :
			handleInfoMessage( iq );
		
		default :
		}
	}
	
	function connectTransport() {
		transport = currentTransports[currentTransportIndex];
		transport.__onConnect = handleTransportConnect;
		transport.__onFail = handleTransportFail;
		transport.connect();
	}
	
	function handleTransportConnect() {
		transport.__onPublish = handleTransportPublish;
		onConnect();
		//if( !manualPublish )
	//		transport.publish( record );
	}
	
	function handleTransportPublish() {
		stream.sendPacket( IQ.createResult( sessionAcceptIQ ) ); // send accept response 
		onInit();
	}
	
	function handleTransportFail() {
		trace("handleTransportFail");
	}
	
	override function cleanup() {
		if( transport != null && transport.connected ) {
			transport.close();
			transport = null;
		}
		super.cleanup();
	}
	
}
