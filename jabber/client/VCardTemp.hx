package jabber.client;

import jabber.event.VCardEvent;
import xmpp.IQ;
import xmpp.IQType;
import xmpp.iq.VCard;


/**
	<a href="http://www.xmpp.org/extensions/xep-0054.html">XEP-0054: vcard-temp</a>
*/
class VCardTemp {
	
	public var stream(default,null) : Stream;
	public var loaded(default,null) : { from:String, data:VCard };
	public var updated(default,null) : VCard;
	
	var iq_load	: IQ;
	var iq_update : IQ;
	
	
	public function new( stream : Stream ) {
		
		this.stream = stream;
		//stream.features.add( this );
		
		iq_load = new IQ();
		iq_load.ext = new VCard();
		
		iq_update = new IQ( IQType.set, null, stream.jid.domain );
		
		//TODO collect/handle incoming vcard requests (?)
	}
	
	
	public dynamic function onLoad( vc : VCardEvent ) {
		// i am yours.
	}
	public dynamic function onUpdated( vc : VCardEvent ) {
		// i am yours.
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
	public function update( vc : xmpp.iq.VCard ) {
		iq_update.ext = vc;
		stream.sendIQ( iq_update, handleUpdate );
	}
	
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result :
				trace("RRRRESULT");
				//loaded = {from:iq.from, data:VCard.parse( iq.ext.toXml() ) };
				onLoad( new VCardEvent( stream, iq.from, VCard.parse( iq.ext.toXml() ) ) );
			//	onLoad( new VCardEvent( stream, iq ) );
				
			case error :
				//TODO
			default : //#
		}
	}
	
	function handleUpdate( iq : IQ ) {
		switch( iq.type ) {
			case result : //onUpdate.dispatchEvent( { from : iq.from, data : IQVCard.parse( iq.extension.toXml() ) } );
			case error :
				//TODO
			default : //
		}
	}
	
}
	 