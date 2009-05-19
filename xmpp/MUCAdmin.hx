package xmpp;

class MUCAdmin {
	
	public static var XMLNS = xmpp.MUC.XMLNS+"#admin";
	
	public var items : Array<xmpp.muc.Item>;
	
	public function new() {
		items = new Array();
	}

	public function toXml() : Xml {
		var x = Xml.createElement( "query" );
		x.set( "xmlns", XMLNS );
		for( i in items ) x.addChild( i.toXml() );
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	public static function parse( x : Xml ) : xmpp.MUCAdmin {
		var p = new MUCAdmin();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "item" : p.items.push( xmpp.muc.Item.parse( e ) );	
			}
		}
		return p;
	}
	
}
