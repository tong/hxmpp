package xmpp.disco;

class Item {
	
	public var jid : String;
	public var name : String;
	public var node : String;
	
	public function new( jid : String, ?name : String, ?node : String ) {
		this.jid = jid;
		this.name = name;
		this.node = node;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "item" );
		x.set( "jid", jid );
		if( name != null ) x.set( "name", name );
		if( node != null ) x.set( "node", node );
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	public static function parse( x : Xml ) : xmpp.disco.Item {
		return new Item( x.get( "jid" ), x.get( "name" ), x.get( "node" ) );
	}
	
}
