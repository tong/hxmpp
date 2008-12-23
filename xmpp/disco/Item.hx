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
	
	#if JABBER_DEBUG public inline function toString() : String { return toXml().toString(); } #end
	
	public static function parse( x : Xml ) : xmpp.disco.Item {
		var i = new Item( x.get( "jid" ) );
		i.jid = x.get( "jid" );
		i.name = x.get( "name" );
		i.node = x.get( "node" );
		return i;
	}
	
}
