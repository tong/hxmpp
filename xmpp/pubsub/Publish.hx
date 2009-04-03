package xmpp.pubsub;


class Publish extends List<Item> {
	
	public var node : String;
	
	public function new( node : String, ?items : Iterable<Item> ) {
		super();
		this.node = node;
		if( items!= null )
			for( i in items )
				add( i );
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "publish" );
		x.set( "node", node );
		for( i in iterator() )
			x.addChild( i.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Publish {
		var p = new Publish( x.get( "node" ) );
		for( e in x.elementsNamed( "item" ) )
			p.add( Item.parse( e ) );
		return p;
	}
	
}
