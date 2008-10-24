package xmpp.dataform;


class Reported extends Item {
	
	public function new( ?fields : Array<Field> ) {
		super( fields );
	}
	
	public override function toXml() : Xml {
		return createXml( "reported" );
	}
	
	public static function parse( x : Xml ) : Reported {
		return cast Field.parseFields( new Reported(), x );
	}
	
}
