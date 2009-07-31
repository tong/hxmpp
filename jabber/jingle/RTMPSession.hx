package jabber.jingle;

import jabber.stream.PacketCollector;
import jabber.jingle.transport.RTMPOutput;
import xmpp.jingle.TCandidateRTMP;

/**
	Outgoing jingle RTMP session.
*/
class RTMPSession extends Session {
	
	public dynamic function onInit() : Void;
	
	/** Known transports */
	public var transports(default,null) : Array<RTMPOutput>; //TODO TRTMPCandidate (?) 
	/** Transport used */
	public var transport(default,null) : RTMPOutput;
	
	var c : PacketCollector;
	
	public function new( stream : jabber.Stream, entity : String ) {
		super( stream );
		this.entity = entity;
		transports = new Array();
	}
	
	public function init() {
		
		if( transports.length == 0 )
			throw "No RTMP transports registered";
			
		//TODO activate (local) streamservers ??
		sid = util.StringUtil.random64( 16 );
		
		// create session offer
		var iq = new xmpp.IQ( xmpp.IQType.set, null, entity );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_initiate, stream.jidstr, sid );
		var content = new xmpp.jingle.Content( jabber.JIDUtil.parseBare( stream.jidstr ), "av" );
		//TODO description
		var xt = Xml.createElement( "transport" );
		xt.set( "xmlns", "urn:xmpp:jingle:apps:rtmp" );
		for( t in transports ) {
			xt.addChild( new xmpp.jingle.Candidate<TCandidateRTMP>( { name : t.name, host : t.host, port : t.port, id : t.id } ).toXml() );
		}
		content.any.push( xt );
		j.content.push( content );
		iq.x = j;
		// collect jingle session packets
		c = new PacketCollector( [ cast new xmpp.filter.PacketFromFilter( entity ), cast new xmpp.filter.IQFilter( xmpp.Jingle.XMLNS, xmpp.Jingle.NODENAME, xmpp.IQType.set ) ], handleSessionPacket, true );
		stream.addCollector( c );
		// send offer
		//stream.sendIQ( iq, handleSessionInitResponse );
		stream.sendIQ( iq );
	}
	
	public override function terminate( reason : xmpp.jingle.Reason ) {
		transport.close();
		super.terminate( reason );
		//onEnd( this );
	}
	
	/*
	function handleSessionInitResponse( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			trace("RRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRRR");
			//////c = new PacketCollector( [ cast new xmpp.filter.PacketFromFilter( entity ), cast new xmpp.filter.IQFilter( xmpp.Jingle.XMLNS, xmpp.Jingle.NODENAME, xmpp.IQType.set ) ], handleSessionAccept );
			//c = new PacketCollector( [ cast new xmpp.filter.PacketFromFilter( entity ), cast new xmpp.filter.IQFilter( xmpp.Jingle.XMLNS, xmpp.Jingle.NODENAME, xmpp.IQType.set ) ], handleSessionPacket, true );
			//stream.addCollector( c );
		case error :
			//onError( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
	*/

	function handleSessionPacket( iq : xmpp.IQ ) {
		var j = xmpp.Jingle.parse( iq.x.toXml() );
		switch( iq.type ) {
		case set :
			switch( j.action ) {
			
			case session_accept :
				if( transport != null ) {
					//TODO return error
					trace("Invalid request, session already active");
					return;
				}
				trace( "Jingle session accepted ..." );
				var content = j.content[0]; //TODO
				var candidates = new Array<xmpp.jingle.TCandidateRTMP>();
				for( h in content.transport.elements )
					candidates.push( xmpp.jingle.Candidate.parse( h ) );
				var transports_ok = new Array<RTMPOutput>();
				for( c in candidates )
					for( t in transports )
						if( t.name == c.name && t.host == c.host && t.port == c.port && t.id == c.id )
							transports_ok.push( t );
				if( transports_ok.length == 0 ) {
					trace("TODO No valid transport selected");
					return;
				}
				// fire accept event
				//onAccept( this );
				// connect transport	
				var me = this;
				transport = transports_ok[0]; //TODO!!!!!!!!!!!
				transport.__onFail = handleTransportFail;
				me.transport.__onPublish = function() {
					// send accept response
					me.stream.sendPacket( new xmpp.IQ( xmpp.IQType.result, iq.id, me.entity ) );
					// fire session initialized event
					me.onInit();
					// collect session close packets
					// TODO
				};
				transport.__onConnect = transport.publish;
				transport.connect();
		
			case session_info :
				handleSessionInfoMessage( iq );
				
			case session_terminate :
				if( transport == null ) {
					return;
				}
				transport.close();
				handleSessionTerminate( iq );
				
			default :
				
			}
				
		default :	
		}
	}
	
	function handleTransportDisconnect() {
		trace("handleTransportDisconnect");
	}
	
	function handleTransportFail() {
		trace("handleTransportFail");
	}
	
}
