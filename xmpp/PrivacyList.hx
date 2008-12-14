package xmpp;


class PrivacyList {
	
	public var name : String;
	public var items : Array<xmpp.privacylist.Item>;
	
	
	public function new( name : String ) {
		this.name = name;
		items = new Array();
	}
	
	
	public function toXml() : Xml {
		var x = Xml.createElement( "list" );
		x.set( "name", name );
		for( i in items ) x.addChild( i.toXml() );
		return x;	
	}
	
	#if JABBER_DEBUG public inline function toString() : String { return toXml().toString(); } #end
	
	
	public static function parse( x : Xml ) : xmpp.PrivacyList {
		var p = new xmpp.PrivacyList( x.get( "name" ) );
		for( e in x.elementsNamed( "item" ) ) {
			p.items.push( xmpp.privacylist.Item.parse( e ) );
		} 
		return p;
	}
	
}
