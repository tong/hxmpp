package xmpp;


class PrivacyLists {
	
	public static var XMLNS = "jabber:iq:privacy";
	
	public var active : String;
	public var _default : String;
	public var list : Array<xmpp.PrivacyList>;
	

	public function new() {
		list = new Array();
	}
	
	
	public function toXml() : Xml {
		var q = xmpp.IQ.createQueryXml( XMLNS );
		if( active != null ) {
			var e = Xml.createElement( "active" );
			if( active != "" ) e.set( "name", active );
			q.addChild( e );
		}
		if( _default != null ) {
			var e = Xml.createElement( "default" );
			e.set( "name", _default );
			q.addChild( e );
		}
		for( l in list ) q.addChild( l.toXml() );
		return q;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	
	public static function parse( x : Xml ) : xmpp.PrivacyLists {
		var p = new xmpp.PrivacyLists();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
				case "active" : p.active = e.get( "name" );
				case "default" : p._default = e.get( "name" );
				case "list" : p.list.push( xmpp.PrivacyList.parse( e ) );
			}
		}
		return p;
	}
	
}
