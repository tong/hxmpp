package jabber.client;


/**
	<a href="http://www.xmpp.org/extensions/xep-0054.html">XEP-0054: vcard-temp</a>
*/
//TODO VCard
class VCardTemp {
	
	public dynamic function onLoad( d : VCardTemp, node : String, data : xmpp.VCard ) : Void;
	public dynamic function onUpdate( d : VCardTemp, data : xmpp.VCard ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	
	var iq_load	: xmpp.IQ;
	var iq_update : xmpp.IQ;
	
	
	public function new( stream : Stream ) {
		
		this.stream = stream;
		
		iq_load = new xmpp.IQ();
		iq_load.ext = new xmpp.VCard();
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
		iq_update.ext = vc;
		stream.sendIQ( iq_update, handleUpdate );
	}
	
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result :
				onLoad( this, iq.from, xmpp.VCard.parse( iq.ext.toXml() ) );
			case error :
				onError( new jabber.XMPPError( this, iq ) );
			default : //#
		}
	}
	
	function handleUpdate( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result :
				onUpdate( this, xmpp.VCard.parse( iq.ext.toXml() ) );
			case error :
				onError( new jabber.XMPPError( this, iq ) );
			default : //
		}
	}
	
}
	 