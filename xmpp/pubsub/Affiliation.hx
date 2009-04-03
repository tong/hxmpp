package xmpp.pubsub;

class Affiliation {
	
	public var node : String;
	public var affiliation : AffiliationState;
	
	public function new( node : String, affiliation : AffiliationState ) {
		this.node = node;
		this.affiliation = affiliation;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "affiliation" );
		x.set( "node", node );
		x.set( "affiliation", Type.enumConstructor( affiliation ) );
		return x;
	}
	
	public static function parse( x : Xml) : Affiliation {
		return new Affiliation( x.get( "node" ), Type.createEnum( AffiliationState, x.get( "affiliation" ) ) );
	}
	
}
