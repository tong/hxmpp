package jabber;

/**
	Send personal updates or "events" to other users, who are typically contacts in the user's roster.
	<a href="http://xmpp.org/extensions/xep-0163.html">XEP-0163: Personal Eventing Protocol</a>
*/
class PersonalEvent {
	
	public dynamic function onPublish( i : xmpp.pep.Event ) : Void;
	public dynamic function onDisable( i : xmpp.pep.Event ) : Void;
	public dynamic function onError( e : XMPPError ) : Void;
	
	public var stream(default,null) : Stream;
	
	public function new( stream : jabber.Stream ) {
		this.stream = stream;
		//TODO add to stream features
	}
	
	/**
		Publish a personal event.
	*/
	public function publish( e : xmpp.pep.Event ) {
		sendIQ( e, e.toXml(), onPublish );
	}
	
	/**
		Disable publishing.
		//TODO ?? hmm public function disable( c : Class<xmpp.pep.Event> ) {
	*/
	public function disable( e : xmpp.pep.Event ) {
		sendIQ( e, e.empty(), onDisable );
	}
	
	function sendIQ( e : xmpp.pep.Event, x : Xml, h : xmpp.pep.Event->Void ) {
		var p = new xmpp.pubsub.Publish( e.getNode(), [new xmpp.pubsub.Item( null, x )] );
		var xt = new xmpp.PubSub();
		xt.publish = p;
		var iq = new xmpp.IQ( xmpp.IQType.set, null );
		iq.ext = xt;
		var me = this;
		stream.sendIQ( iq, function(r:xmpp.IQ) {
			switch( r.type ) {
			case result : h( e );
			case error : me.onError( new jabber.XMPPError( me, r ) );
			default : //#
			}
		} );
	}
	
}
