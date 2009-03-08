package xmpp;


class X {
	
	public static function create( xmlns : String, ?childs : Iterable<Xml> ) : Xml {
		var x = Xml.createElement( "x" );
		x.set( "xmlns", xmlns );
		if( childs != null ) 
			for( c in childs )
				x.addChild( c );
		return x;
	}
	
}
