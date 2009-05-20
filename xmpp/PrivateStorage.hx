package xmpp;

class PrivateStorage {
	
	public static var XMLNS = "jabber:iq:private";
	
	public var name : String;
	public var namespace : String;
	public var data : Xml;
	
	public function new( name : String, namespace : String, ?data : Xml ) {
		this.name = name;
		this.namespace = namespace;
		this.data = data;
	}
	
	public function toXml() : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		var e = Xml.createElement( name );
		e.set( "xmlns", namespace );
		if( data != null ) e.addChild( data );
		x.addChild( e );
		return x;
	}
	
	public static function parse( x : Xml ) : PrivateStorage {
		var e = x.firstChild();
		return new PrivateStorage( e.nodeName, e.get("xmlns" ), e.firstElement() );
	}
	
}
