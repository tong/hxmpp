package jabber.client;

import jabber.event.IQResult;
import xmpp.IQ;


/**
	<a href="http://www.xmpp.org/extensions/xep-0054.html">XEP-0054: vcard-temp</a>
*/
class VCardTemp {
	
	public dynamic function onLoad( r : IQResult<Stream,xmpp.VCard> ) : Void;
	public dynamic function onUpdated( r : IQResult<Stream,xmpp.VCard> ) : Void;
	public dynamic function onError( e : jabber.event.XMPPErrorEvent<Stream> ) : Void;
	
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
				var e = new IQResult<Stream,xmpp.VCard>( stream, iq, l );
				onLoad( e );
				
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
	 