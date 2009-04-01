package xmpp.disco;


/**
*/
class Items extends List<xmpp.disco.Item> {

	public static var XMLNS = xmpp.NS.PROTOCOL+'/disco#items';
	
	public var node : String;
	
	
	public function new( ?node : String ) {
		super();
		this.node = node;
	}
	
	
	public function toXml() : Xml {
		var q = xmpp.IQ.createQueryXml( XMLNS );
		if( node != null ) q.set( "node", node );
		if( !isEmpty() ) {
			for( i in iterator() ) {
				var item = Xml.createElement( 'item' );
				if( i.jid != null ) item.set( "jid", i.jid );
				if( i.name != null ) item.set( "name", i.name );
				q.addChild( item );
			}
		}
		return q;
	}
	
	
	public static function parse( x : Xml ) : Items {
		var items = new Items();
		for( f in x.elements() ) {
			switch( f.nodeName ) {
				case "item" : items.add( xmpp.disco.Item.parse( f ) );
			}
		}
		return items;
	}
	
}
