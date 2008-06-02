package xmpp.iq;




class DiscoItems extends List<DiscoItem> {

	public static inline var XMLNS = 'http://jabber.org/protocol/disco#items';
	
	
	public function new() {
		super();
	}
	
	
	public function toXml() : Xml {
		var query = xmpp.IQ.createQuery( XMLNS );
		if( !isEmpty() ) {
			for( i in iterator() ) {
				var item = Xml.createElement( 'item' );
				if( i.jid != null ) item.set( "jid", i.jid );
				if( i.name != null ) item.set( "name", i.name );
				query.addChild( item );
			}
		}
		return query;
	}
	
	
	public static function parse( child : Xml ) : DiscoItems {
		var items = new DiscoItems();
		for( f in child.elements() ) {
			switch( f.nodeName ) {
				case "item" : items.add( DiscoItem.parse( f ) );
			}
		}
		return items;
	}
}


class DiscoItem {
	
	public var jid : String; // required
	public var name : String;
	public var node : String;
	public var action : String;
	
	/*TODO
	<xs:simpleType>
              <xs:restriction base='xs:NCName'>
                <xs:enumeration value='remove'/>
                <xs:enumeration value='update'/>
              </xs:restriction>
            </xs:simpleType>
	
	*/
	
	public function new( jid : String, ?name : String, ?node : String, ?action : String ) {
		this.jid = jid;
		this.name = name;
		this.node = node;
		this.action = action;
	}
	
	
	public function toXml() : Xml {
		var xml = Xml.createElement( "item" );
		xml.set( "jid", jid );
		if( name != null ) xml.set( "name", name );
		if( node != null ) xml.set( "node", node );
		if( action != null ) xml.set( "node", action );
		return xml;
	}
	
	
	public static function parse( child : Xml ) : DiscoItem {
		var item = new DiscoItem( child.get( "jid" ) );
		//item.jid = child.get( "jid" );
		item.name = child.get( "name" );
		item.node = child.get( "node" );
		item.action = child.get( "action" );
		return item;
	}
}
