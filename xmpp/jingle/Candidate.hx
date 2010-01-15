package xmpp.jingle;

/**
	Jingle transport candidate.
*/
class Candidate<T> {
	
	public var attributes : T;
	
	public function new( ?a : T ) {
		attributes = a;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "candidate" );
		for( f in Reflect.fields( attributes ) )
			x.set( f, Reflect.field( attributes, f ) );
		return x;
	}
	
	public static function parse<T>( x : Xml ) : T {
		var c : T = cast {};
		for( e in x.attributes() )
			Reflect.setField( c, e, x.get( e ) );
		return c;
	}
	
	public static function parseTransportCandidates<T>( x : Xml ) : Array<T> {
		var c : Array<T> = new Array();
		for( e in x.elementsNamed( "candidate" ) )
			c.push( xmpp.jingle.Candidate.parse( e ) );
		return c;
	}
	
	//public static function copy<T>( c : Candidate<T> ) : Candidate<T> 
}
