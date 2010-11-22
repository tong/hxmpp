package jabber.jingle;

import jabber.jingle.io.Transport;
import jabber.util.Base64;
import xmpp.IQ;
import xmpp.IQType;

class OutgoingSession<T:Transport> extends Session<T> {
	
	public var transports(default,null) : Array<T>;
	
	function new( stream : jabber.Stream, entity : String, contentName : String, xmlns : String ) {
		super( stream, xmlns );
		this.entity = entity;
		this.contentName = contentName;
		transports = new Array();
	}
	
	public function init() {
		if( transports.length == 0 )
			throw "No transports registered";
		sid = Base64.random( 16 );
		var iq = new IQ( IQType.set, null, entity );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_initiate, stream.jidstr, sid );
		var content = new xmpp.jingle.Content( xmpp.jingle.Creator.initiator, contentName );
		content.other.push( createTransportXml() );
		//TODO add description..
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
		x.set( "xmlns", xmlns );
		for( t in transports ) x.addChild( t.toXml() );
		return x;
	}
	
}
