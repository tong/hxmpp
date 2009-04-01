package xmpp.disco;


/**
*/
class Info {
	
	public static var XMLNS = xmpp.NS.PROTOCOL+'/disco#info';
	
	public var identities : Array<xmpp.disco.Identity>; 
	public var features : Array<String>;
	public var node : String;
	
	public function new( ?identities : Array<xmpp.disco.Identity>, ?features : Array<String>, ?node : String ) {
		this.identities = ( identities == null ) ? new Array() : identities;
		this.features = ( features == null ) ? new Array() : features;
		this.node = node;
	}
	

	public function toXml() : Xml {
		var x = xmpp.IQ.createQueryXml( XMLNS );
		if( node != null ) x.set( "node", node );
		for( i in identities ) {
			var identity = Xml.createElement( 'identity' );
			if( i.category != null ) identity.set( "category", i.category );
			if( i.name != null ) identity.set( "name", i.name );
			if( i.type != null ) identity.set( "type", i.type );
			x.addChild( identity );
		}
		if( features.length > 0 ) {
			for( f in features ) {
				var feature = Xml.createElement( 'feature' );
				feature.set( "var", f );
				x.addChild( feature );
			}
		}
		return x;
	}
	
	public inline function toString() {
		return toXml().toString();
	}
	
	
	public static function parse( x : Xml ) : xmpp.disco.Info {
		var i = new Info( null, null, x.get( "node" ) );
		for( f in x.elements() ) {
			switch( f.nodeName ) {
				case "feature"  : i.features.push( f.get( "var" ) );
				case "identity" : i.identities.push( { category : f.get( "category" ),
													   name : f.get( "name" ),
													   type : f.get( "type" ) } );
			}
		}
		return i;
	}
	
}
