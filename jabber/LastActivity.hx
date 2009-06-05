package jabber;

/**
	<a href="http://xmpp.org/extensions/xep-0012.html">XEP-0012: Last Activity</a><br/>
*/
class LastActivity {
	
	public dynamic function onLoad( entity : String, secs : Int ) {}
	public dynamic function onError( e : XMPPError ) {}
	
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	/**
		Requests the given entity for their last activity.
		Given a bare jid will be handled by the server on roster subscription basis.
		Otherwise the request will be fowarded to the resource of the client entity.
	*/
	public function request( jid : String ) {
		var iq = new xmpp.IQ( null, null, jid );
		iq.x = new xmpp.LastActivity();
		stream.sendIQ( iq, handleLoad );
	}
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result :
			onLoad( iq.from, xmpp.LastActivity.parseSeconds( iq.x.toXml() ) );
		case error :
			onError( new XMPPError( this, iq ) );
		default : //#
		}
	}
	
}
