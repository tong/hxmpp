package xmpp.pubsub;

class Affiliations extends List<Affiliation> {
	
	public function new() {
		super();
	}
	
	public function toXml() {
		var x = Xml.createElement( "affiliations" );
		for( s in iterator() )
			x.addChild( s.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Affiliations {
		var a = new Affiliations();
		for( e in x.elementsNamed( "affiliation" ) )
			a.add( Affiliation.parse( e ) );
		return a;
	}
	
}
