package xmpp;


class X {
	
	public static function create( xmlns : String, ?child : Xml ) : Xml {
		var x = Xml.createElement( "x" );
		x.set( "xmlns", xmlns );
		if( child != null ) x.addChild( child );
		return x;
	}
	
}
