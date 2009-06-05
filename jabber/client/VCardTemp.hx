package jabber.client;

/**
	<a href="http://www.xmpp.org/extensions/xep-0054.html">XEP-0054: vcard-temp</a>
*/
//TODO VCard
class VCardTemp {
	
	public dynamic function onLoad( node : String, data : xmpp.VCard ) : Void;
	public dynamic function onUpdate( data : xmpp.VCard ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	
	var iq_load	: xmpp.IQ;
	var iq_update : xmpp.IQ;
	
	
	public function new( stream : Stream ) {
		
		this.stream = stream;
		
		iq_load = new xmpp.IQ();
		iq_load.x = new xmpp.VCard();
		iq_update = new xmpp.IQ( xmpp.IQType.set, null, stream.jid.domain );
	}
	
	
	/**
		Requests to load the vcard from the given entity or from its own if no argument given.
	*/
	public function load( ?jid : String  ) {
		iq_load.to = jid;
		stream.sendIQ( iq_load, handleLoad );
	}
	
	/**
		Update own vcard.
	*/
	public function update( vc : xmpp.VCard ) {
		iq_update.x = vc;
		stream.sendIQ( iq_update, handleUpdate );
	}
	
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result :
				onLoad( iq.from, if( iq.x != null ) xmpp.VCard.parse( iq.x.toXml() ) else null );
			case error :
				onError( new jabber.XMPPError( this, iq ) );
			default : //#
		}
	}
	
	function handleUpdate( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result :
				onUpdate( xmpp.VCard.parse( iq.x.toXml() ) );
			case error :
				onError( new jabber.XMPPError( this, iq ) );
			default : //
		}
	}
	
}
	 