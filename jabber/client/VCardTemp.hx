package jabber.client;

/**
	<a href="http://www.xmpp.org/extensions/xep-0054.html">XEP-0054: vcard-temp</a>
*/
class VCardTemp {
	
	public dynamic function onLoad( node : String, data : xmpp.VCard ) : Void;
	public dynamic function onUpdate( data : xmpp.VCard ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		this.stream = stream;
	}
	
	/**
		Requests to load the vcard from the given entity or from its own if no argument given.
	*/
	public function load( ?jid : String  ) {
		var iq = new xmpp.IQ( null, null, jid );
		iq.x = new xmpp.VCard();
		stream.sendIQ( iq, handleLoad );
	}
	
	/**
		Update own vcard.
	*/
	public function update( vc : xmpp.VCard ) {
		var iq = new xmpp.IQ( xmpp.IQType.set, null, stream.jid.domain );
		iq.x = vc;
		stream.sendIQ( iq, handleUpdate );
	}
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onLoad( iq.from, if( iq.x != null ) xmpp.VCard.parse( iq.x.toXml() ) else null );
		case error : onError( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
	
	function handleUpdate( iq : xmpp.IQ ) {
		switch( iq.type ) {
		case result : onUpdate( xmpp.VCard.parse( iq.x.toXml() ) );
		case error : onError( new jabber.XMPPError( this, iq ) );
		default : //#
		}
	}
	
}
	 