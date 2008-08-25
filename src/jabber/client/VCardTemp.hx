package jabber.client;

import event.Dispatcher;
import xmpp.IQ;
import xmpp.IQVCard;



typedef VCardChange = {
	var from : String;
	var data : xmpp.IQVCard;
}


/**
	<a href="http://www.xmpp.org/extensions/xep-0054.html">XEP-0054: vcard-temp</a>
*/
class VCardTemp {
	
	public var onLoad(default,null)   : Dispatcher<VCardChange>;
	public var onUpdate(default,null) : Dispatcher<VCardChange>;
	public var stream(default,null) : Stream;
	
	var iq_load	: IQ;
	var iq_update : IQ;
	
	
	public function new( stream : Stream ) {
		
		this.stream = stream;
		
		iq_load = new IQ();
		iq_load.extension = new IQVCard();
		
		iq_update = new IQ( IQType.set, null, stream.jid.domain );
		
		onLoad = new Dispatcher();		
		onUpdate = new Dispatcher();
		
		//TODO collect/handle incoming vcard requests (?)
	}
	
	
	/**
		Requests to load the vcard from the given entity, or itself if no argument given.
	*/
	public function load( ?jid : String  ) {
		iq_load.to = jid;
		stream.sendIQ( iq_load, handleLoad );
	}
	
	/**
		Update own vcard.
	*/
	public function update( vc : IQVCard ) {
		iq_update.extension = vc;
		stream.sendIQ( iq_update, handleUpdate );
	}
	
	
	function handleLoad( iq : IQ ) {
		switch( iq.type ) {
			case result :
				trace("VCADLOAD");
				onLoad.dispatchEvent( { from : iq.from, data : IQVCard.parse( iq.extension.toXml() ) } );
			case error :
				//TODO
			default : //#
		}
	}
	
	function handleUpdate( iq : IQ ) {
		switch( iq.type ) {
			case result : onUpdate.dispatchEvent( { from : iq.from, data : IQVCard.parse( iq.extension.toXml() ) } );
			case error :
				//TODO
			default : //
		}
	}
	
}
	 