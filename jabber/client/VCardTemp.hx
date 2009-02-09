package jabber.client;

import xmpp.IQ;


/**
	<a href="http://www.xmpp.org/extensions/xep-0054.html">XEP-0054: vcard-temp</a>
*/
//TODO VCard
class VCardTemp {
	
	//TODO
	public dynamic function onLoad( d : VCardTemp, node : String, data : xmpp.VCard ) : Void;
	public dynamic function onUpdated( d : VCardTemp, node : String, data : xmpp.VCard ) : Void;
	public dynamic function onError( e : jabber.XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	
	var iq_load	: IQ;
	var iq_update : IQ;
	
	
	public function new( stream : Stream ) {
		
		this.stream = stream;
		//stream.features.add( this );
		
		iq_load = new IQ();
		iq_load.ext = new xmpp.VCard();
		iq_update = new IQ( xmpp.IQType.set, null, stream.jid.domain );
		// collect/handle incoming vcard requests (?) jabber.VCardTempListener ?
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
	
	
	function handleLoad( iq : IQ ) {
		switch( iq.type ) {
			case result :
				var l = xmpp.VCard.parse( iq.ext.toXml() );
				onLoad( this, iq.from, l );
				
			case error :
				//TODO
				//stream.onError.?
				
			default : //#
		}
	}
	
	function handleUpdate( iq : IQ ) {
		switch( iq.type ) {
			case result :
				//onUpdate( { from : iq.from, data : IQVCard.parse( iq.extension.toXml() ) } );
			case error :
				//TODO
			default : //
		}
	}
	
}
	 