package jabber;

import jabber.core.StreamBase;


class LastActivity extends xmpp.LastActivity {
	
	public var from(default,null) : String;
	public var stream(default,null) : StreamBase;
	public var error : xmpp.Error;
	
	public function new( stream : StreamBase, from : String ) {
		super();
		this.stream = stream;
		this.from = from;
	}
}


/**
	<a href="http://xmpp.org/extensions/xep-0012.html">XEP-0012: Last Activity</a><br/>
*/
class LastActivityQuery {
	
	public dynamic function onLoad( e : LastActivity ) {}
	
	public var stream : StreamBase;
	
	var iq : xmpp.IQ;
	
	
	public function new( stream : StreamBase ) {
		this.stream = stream;
		iq = new xmpp.IQ();
		iq.ext = new xmpp.LastActivity();
	}
	
	
	/**
		Requests the given entity for their last activity.
		Given a bare jid will be handled by the server on roster subscription basis.
		Otherwise the request will be fowarded to the resource of the client entity.
	*/
	public function request( jid : String ) {
		iq.to = jid;
		stream.sendIQ( iq, handleLoad );
	}
	
	
	function handleLoad( iq : xmpp.IQ ) {
		var e = new LastActivity( stream, iq.from );
		switch( iq.type ) {
			case result :
				e.seconds = xmpp.LastActivity.parseSeconds( iq.ext.toXml() );
				onLoad( e );
			case error :
				e.error = xmpp.Error.parsePacket( iq );
				onLoad( e );
			default : //
		}
	}
	
}
