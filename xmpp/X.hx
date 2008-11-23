package xmpp;


class X {
	
	public static inline function create( xmlns : String ) {
		var x = Xml.createElement( "x" );
		x.set( "xmlns", xmlns );
		//children...
		return x;
	}
	
}
