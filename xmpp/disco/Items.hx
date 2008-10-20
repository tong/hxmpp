package xmpp.disco;


/**
*/
class Items extends List<xmpp.disco.Item> {

	public static var XMLNS = 'http://jabber.org/protocol/disco#items';
	
	
	public function new() {
		super();
	}
	
	
	public function toXml() : Xml {
		var q = xmpp.IQ.createQuery( XMLNS );
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
