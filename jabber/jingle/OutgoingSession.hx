package jabber.jingle;

import jabber.jingle.io.Transport;
import jabber.util.Base64;
import xmpp.IQ;
import xmpp.IQType;

class OutgoingSession<T:Transport> extends Session<T> {
	
	/** Offered transports */
	public var transports(default,null) : Array<T>;
	
	function new( stream : jabber.Stream, entity : String, contentName : String, xmlns : String ) {
		super( stream, xmlns );
		this.entity = entity;
		this.contentName = contentName;
		transports = new Array();
	}
	
	public function init() {
		sendSessionInit();
	}
	
	function sendSessionInit( ?description : Xml ) {
		if( transports.length == 0 )
			throw new jabber.error.Error( "No transports registered" );
		sid = Base64.random( 16 );
		var iq = new IQ( IQType.set, null, entity );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_initiate, stream.jid.toString(), sid );
		var content = new xmpp.jingle.Content( xmpp.jingle.Creator.initiator, contentName );
		if( description != null ) content.other.push( description );
		content.other.push( createTransportXml() );
		j.content.push( content );
		iq.x = j;
		addSessionCollector();
		stream.sendIQ( iq, handleSessionInitResponse );
	}
	
	function handleSessionInitResponse( iq : IQ ) {
		switch( iq.type ) {
//		case result :
//			trace(">>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>>");
		case error :
			onError( new jabber.XMPPError( this, iq ) );
			cleanup();
		default :
		}
	}
	
	function createTransportXml() : Xml {
		var x = Xml.createElement( "transport" );
		#if flash //TODO flash 2.06
		x.set( "_xmlns_", xmlns );
		#else
		x.set( "xmlns", xmlns );
		#end
		for( t in transports )
			x.addChild( createCandidateXml( t ) );
		return x;
	}
	
	function createCandidateXml( t : Transport ) : Xml {
		return t.toXml();
	}
	
}
