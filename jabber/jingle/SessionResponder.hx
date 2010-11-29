package jabber.jingle;

import jabber.jingle.io.Transport;
import xmpp.IQ;

class SessionResponder<T:Transport> extends Session<T> {
	
	public function new( stream : jabber.Stream, xmlns : String ) {
		super( stream, xmlns );
	}
	
	public function handleRequest( iq : IQ ) : Bool {
		trace("handleRequesthandleRequesthandleRequesthandleRequesthandleRequest");
		var j = xmpp.Jingle.parse( iq.x.toXml() );
		if( j.action != xmpp.jingle.Action.session_initiate )
			return false;
		var content = j.content[0];
		candidates = new Array();
		for( e in content.other ) {
			switch( e.nodeName ) {
			case "description" :
				parseDescription( e );
			case "transport" :
				/* TODO
				#if flash
				if( e.get( "_xmlns_" ) != xmlns ) {
				#else
				if( e.get( "xmlns" ) != xmlns ) {
				#end
					trace("TODO invalid transport specified");
					trace(e);
					trace( e.get( "xmlns" )+" ::: "+xmlns);
					return false;
				}
				*/
				for( cx in e.elementsNamed( "candidate" ) ) {
					addTransportCandidate( cx );
				}
			}
		}
		if( candidates.length == 0 ) {
			//..TODO
			trace("NO TRANSPORT CANDIDATES FOUND");
			return false;
		}
		request = iq;
		entity = iq.from;
		initiator = j.initiator;
		sid = j.sid;
		contentName = content.name;
		return true;
	}
	
	public function accept( yes : Bool = true ) {
		stream.sendPacket( IQ.createResult( request ) );
		if( yes ) {
			addSessionCollector();
			connectTransport();
		} else {
			terminate( xmpp.jingle.Reason.decline );
		}
	}
	
	function parseDescription( x : Xml ) {
	}
	
	// override me
	function addTransportCandidate( x : Xml ) {
		throw new jabber.error.AbstractError();
	}
	
	override function handleTransportConnect() {
		transport.__onDisconnect = handleTransportDisconnect;
		var iq = new xmpp.IQ( xmpp.IQType.set, null, initiator );
		var j = new xmpp.Jingle( xmpp.jingle.Action.session_accept, initiator, sid );
//		j.responder = stream.jid.toString();
		var content = new xmpp.jingle.Content( xmpp.jingle.Creator.initiator, contentName );
		content.other.push( transport.toXml() );
		j.content.push( content );
		iq.x = j;
		stream.sendIQ( iq, handleSessionAccept );
	}
	
	function handleSessionAccept( iq : IQ ) {
		switch( iq.type ) {
		case result :
			onInit();
			transport.init();
		case error :
			//TODO
		default :
		}
	}
	
}
