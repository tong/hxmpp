package jabber.client;

import jabber.event.IQResult;

/**
	Event, dispatched on vcard load or update.
private class VCardEvent extends xmpp.VCard {
	
	public var from(default,null) : String;
	public var stream(default,null) : Stream;
	//public var error //TODO
	
	public function new( stream : Stream, from : String ) {
		super();
		this.stream = stream;
		this.from = from;
	}
}
*/


/**
	<a href="http://www.xmpp.org/extensions/xep-0054.html">XEP-0054: vcard-temp</a>
*/
class VCardTemp {
	
	public dynamic function onLoad( r : IQResult<Stream,xmpp.VCard> ) {}
	public dynamic function onUpdated( r : IQResult<Stream,xmpp.VCard> ) {}
	public dynamic function onError( e : jabber.event.XMPPErrorEvent<Stream> ) {}
	
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
				var l = xmpp.VCard.parse( iq.ext.toXml() );
				var e = new IQResult<Stream,xmpp.VCard>( stream, iq, l );
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
				//onUpdate( { from : iq.from, data : IQVCard.parse( iq.extension.toXml() ) } );
			case error :
				//TODO
			default : //
		}
	}
	
}
	 