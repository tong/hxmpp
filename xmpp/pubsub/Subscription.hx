package xmpp.pubsub;

class Subscription {
	
	public var jid : String;
	public var node : String;
	public var subid : String;
	public var subscription : SubscriptionState;
	// TODO subscribe_options : Array<>; // xmpp.PubSub only !
	
	public function new( jid : String ) {
		this.jid = jid;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "subscription" );
		x.set( "jid", jid );
		if( node != null ) x.set( "node", node );
		if( subid != null ) x.set( "subid", subid );
		if( subscription != null ) x.set( "subscription", Type.enumConstructor( subscription ) );
		// TODO subscribe_options
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.pubsub.Subscription {
		var s = new Subscription( x.get( "jid" ) );
		if( x.exists( "node" ) ) s.node = x.get( "node" );
		if( x.exists( "subid" ) ) s.subid = x.get( "subid" );
		if( x.exists( "subscription" ) ) s.subscription =  Type.createEnum( SubscriptionState, x.get( "subscription" ) );
		// TODO subscribe_options
		return s;
	}
	
}
