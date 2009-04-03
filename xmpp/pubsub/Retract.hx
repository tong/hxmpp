package xmpp.pubsub;


class Retract extends List<Item> {
		
	public var node : String;
	public var notify : Bool;
	
	public function new( node : String, ?itemIDs : Iterable<String>, ?notify : Bool = false ) {
		super();
		this.node = node;
		if( itemIDs != null )
			for( id in itemIDs ) add( new Item( id ) );
		this.notify = notify;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "retract" );
		x.set( "node", node );
		if( notify ) x.set( "notify", "true" );
		for( i in iterator() )
			x.addChild( i.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Retract {
		var _n = x.get( "notify" );
		var r = new Retract( x.get( "node" ), if( _n != null && ( _n == "true" || _n == "1" ) ) true else false );
		for( e in x.elementsNamed( "item" ) )
			r.add( Item.parse( e ) );
		return r;
	}
	
}
