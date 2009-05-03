package jabber;

/**
	Listens for incoming pubsub events.
	<a href="http://xmpp.org/extensions/xep-0060.html">XEP-0060: Publish-Subscribe</a>
*/
class PubSubListener {
	
	/** Every(!) full pubsub event message */
	public dynamic function onMessage( m : xmpp.Message ) : Void;
	/** Just the pubsub event ( message may contain additional information, like delay,.. ! ) */
	//public dynamic function onEvent( service : String, event : xmpp.PubSubEvent ) : Void;
	/** New pubsub items recieved */
	public dynamic function onItems( service : String, items : xmpp.pubsub.Items ) : Void;
	/** Configuration got changed */
	public dynamic function onConfig( service : String, config : { form : xmpp.DataForm, node : String } ) : Void;
	/** Node got deleted */
	public dynamic function onDelete( service : String, node : String ) : Void;
	/** Node got purged */
	public dynamic function onPurge( service : String, node : String ) : Void;
	/** Subscription action notification */
	public dynamic function onSubscription( service : String, subscription : xmpp.pubsub.Subscription ) : Void;
	
	/////** PubSub services to listen for, others get ignored */
	/////public var targets : List<String>;
	public var stream(default,null) : Stream;
	
	public function new( stream : Stream ) {
		this.stream = stream;
		stream.addCollector( new jabber.stream.PacketCollector( [ cast new xmpp.filter.MessageFilter( xmpp.MessageType.normal ),
																  cast new xmpp.filter.PacketPropertyFilter( xmpp.PubSubEvent.XMLNS, "event" ) ],
																  handlePubSubEvent, true ) );
	}
	
	function handlePubSubEvent( m : xmpp.Message ) {
		
		// fire EVERY event message
		onMessage( m );
		
		var service = m.from;
		var event : xmpp.PubSubEvent = null;
		for( p in m.properties )
			if( p.nodeName == "event" )
				event = xmpp.PubSubEvent.parse( p );
		// fire event
		if( event.items != null ) {
			onItems( service, event.items );
		} else if( event.configuration != null ) {
			onConfig( service, event.configuration );
		} else if( event.delete != null ) {
			onDelete( service, event.delete );
		} else if( event.purge != null ) {
			onPurge( service, event.purge );
		} else if( event.subscription != null ) {
			onSubscription( service, event.subscription );
		} 
		
		//onEvent( service, event );
	}
	
}
