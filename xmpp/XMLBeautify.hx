package xmpp;

using Lambda;

/**
	Utility to 'beautify' a xml string for debugging.
*/
class XMLBeautify {
	
	//#if (cpp||neko||php||nodejs||rhino)
	
	public static function it( t : String ) : String  {
		var x : Xml = null;
		try { x = Xml.parse(t).firstElement(); } catch(e:Dynamic) { return t+'\n'; }
		var b = new StringBuf();
		createNode( x, b, 0 );
		return b.toString();
	}
	
	static function createNode( x : Xml, b : StringBuf, depth : Int ) {
		indent( b, depth );
		b.add( '<' );
		b.add( x.nodeName );
		for( a in x.attributes() ) {
			b.add( ' ' );
			b.add( a );
			b.add( '=' );
			b.add( '"' );
			b.add( x.get( a ) );
			b.add( '"' );
		}
		if( x.elements().hasNext() ) {
			b.add( '>\n' );
			for( e in x.elements() )
				createNode( e, b, depth+1 );
			indent( b, depth );
			b.add( '</' );
			b.add( x.nodeName );
			b.add( '>\n' );
		} else {
			var v = x.firstChild();
			if( v != null ) {
				b.add( '>' );
				b.add( v );
				b.add( '</' );
				b.add( x.nodeName );
				b.add( '>\n' );
			} else {
				b.add( '/>\n' );
			}
		}
	}
	
	static inline function indent( b : StringBuf, n : Int ) for( i in 0...n ) b.add( '\t' )
	
	/* 
	#else
	
	//TODO
	public static inline function it( t : String ) : String  {
		return t;
	}
	
	#end
	*/
	
}
