package xmpp.dataform;

class FieldOption {
	
	public var label : String;
	public var value : String;
	
	public function new( ?label : String, ?value: String ) {
		this.label = label;
		this.value = value;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "option" );
		if( label != null ) x.set( "label", label );
		if( value != null ) x.addChild( util.XmlUtil.createElement( "value", value ) );
		return x;
	}
	
	public static function parse( x : Xml ) : FieldOption {
		var option = new FieldOption();
		option.label = x.get( "label" );
		option.value = x.elements().next().firstChild().nodeValue;
		return option;
	}
}
