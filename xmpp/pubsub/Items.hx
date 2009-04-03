package xmpp.pubsub;

class Items extends List<Item> {
	
	public var node : String;
	public var subid : String;
	public var maxItems : Null<Int>;
	
	public function new( ?node : String, ?subid :String, ?maxItems : Int ) {
		super();
		this.node = node;
		this.subid = subid;
		this.maxItems = maxItems;
		
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "items" );
		if( node != null ) x.set( "node", node );
		if( subid != null ) x.set( "subid", subid );
		if( maxItems != null ) x.set( "max_items", Std.string( maxItems ) );
		for( i in iterator() )
			x.addChild( i.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Items {
		var maxItems = x.get( "maxItems" );
		var i = new Items( x.get( "node" ), x.get( "subid" ), if( maxItems != null ) Std.parseInt( maxItems ) );
		for( e in x.elementsNamed( "item" ) )
			i.add( Item.parse( e ) );
		return i;
	}
	
}
