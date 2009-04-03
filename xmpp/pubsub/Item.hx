package xmpp.pubsub;


class Item {
	
	public var id : String;
	public var payload : Xml; // TODO String ?
	/** The node attribute is allowed (required!) in pubsub-event namespace only! */
	public var node : String;
	
	public function new( ?id : String, ?payload : Xml, ?node : String ) {
		this.id = id;
		this.payload = payload;
		this.node = node;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "item" );
		if( id != null ) x.set( "id", id );
		if( payload != null ) x.addChild( payload );
		if( node != null ) x.set( "node", node );
		return x;
	}
	
	public static function parse( x : Xml ) : Item {
		return new Item( x.get( "id" ), x.firstElement(), x.get( "node" ) );
	}
	
}
