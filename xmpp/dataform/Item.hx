package xmpp.dataform;


class Item {
	
	public var fields : Array<Field>;
	
	public function new( ?fields : Array<Field> ) {
		this.fields = ( fields != null ) ?fields : new Array<Field>();
	}
	
	public function toXml() : Xml {
		return createXml( "item" );
	}
	
	inline function createXml( n : String ) : Xml {
		var x = Xml.createElement( n );
		for( f in fields ) x.addChild( f.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Item {
		return cast Field.parseFields( new Item(), x );
	}
}
