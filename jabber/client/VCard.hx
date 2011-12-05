package jabber.client;

/**
	VCard4
*/
class VCard extends VCardBase<xmpp.VCard> {
	
	public function new( stream : Stream ) {
		super( stream );
	}
	
	/**
		Requests to load the vcard from the given entity or own no jid is given.
	*/
	public override function load( ?jid : String  ) {
		super._load( xmpp.VCard.emptyXml(), jid );
	}
	
	override function _handleLoad( iq : xmpp.IQ ) {
		onLoad( iq.from, ( iq.x != null ) ? xmpp.VCard.parse( iq.x.toXml() ) : null );
	}
	
}
