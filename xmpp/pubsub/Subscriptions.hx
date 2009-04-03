package xmpp.pubsub;

class Subscriptions extends List<Subscription> {
	
	public var node : String;
	
	public function new( ?node : String ) {
		super();
		this.node = node;
	}
	
	public function toXml() {
		var x = Xml.createElement( "subscriptions" );
		if( node != null ) x.set( "node", node );
		for( s in iterator() )
			x.addChild( s.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Subscriptions {
		var s = new Subscriptions( x.get( "node" ) );
		for( e in x.elementsNamed( "subscription" ) )
			s.add( Subscription.parse( e ) );
		return s;
	}
	
}
