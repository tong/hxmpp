package xmpp;

class BlockList {
	
	public static var XMLNS = "urn:xmpp:blocking";
	
	public var items : Array<String>;
	public var unblock : Bool;
	
	public function new( ?items : Array<String>, ?unblock : Bool = false ) {
		this.items = ( items != null ) ? items : new Array();
		this.unblock = unblock;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( (unblock) ? "unblock" : "block" );
		x.set( "xmlns", XMLNS );
		for( i in items ) {
			var e = Xml.createElement( "item" );
			e.set( "jid", i );
			x.addChild( e );
		}
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.BlockList {
		var l = new BlockList();
		for( e in x.elements() )
			l.items.push( e.get( "jid" ) );
		return l;
	}
			
}
