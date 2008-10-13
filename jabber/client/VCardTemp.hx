package jabber.client;


/**
	Event, dispatched on vcard load or update.
*/
class VCardEvent extends xmpp.VCard {
	
	public var from(default,null) : String;
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream, from : String ) {
		super();
		this.stream = stream;
		this.from = from;
	}
	
}


/**
	<a href="http://www.xmpp.org/extensions/xep-0054.html">XEP-0054: vcard-temp</a>
*/
class VCardTemp {
	
	public var stream(default,null) : Stream;
	
	var iq_load	: xmpp.IQ;
	var iq_update : xmpp.IQ;
	
	
	public function new( stream : Stream ) {
		
		this.stream = stream;
		//stream.features.add( this );
		
		iq_load = new xmpp.IQ();
		iq_load.ext = new xmpp.VCard();
		iq_update = new xmpp.IQ( xmpp.IQType.set, null, stream.jid.domain );
		// collect/handle incoming vcard requests (?) jabber.VCardTempListener ?
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
	public function update( vc : xmpp.VCard ) {
		iq_update.ext = vc;
		stream.sendIQ( iq_update, handleUpdate );
	}
	
	
	function handleLoad( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result :
				//TODO
				trace("VCARD RESULT");
				var e = new VCardEvent( stream, iq.from );
				e.injectData( iq.ext.toXml() );
				onLoad( e );
				
			case error :
				//TODO
				//stream.onError.?
				
			default : //#
		}
	}
	
	function handleUpdate( iq : xmpp.IQ ) {
		switch( iq.type ) {
			case result :
				//onUpdate.dispatchEvent( { from : iq.from, data : IQVCard.parse( iq.extension.toXml() ) } );
			case error :
				//TODO
			default : //
		}
	}
	
}
	 