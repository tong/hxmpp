package xmpp.dataform;

import util.XmlUtil;


class Field {
	
	// dirty hack for the enums.
	static inline var hack_enum_from = ~/-/;
	static inline var hack_enum_to = ~/_/;
	
	public var label : String;
	public var type : FieldType;
	public var variable : String;
	public var desc : String;
	public var required : Bool;
	public var values : Array<String>;
	public var options : Array<FieldOption>;
	
	public function new() {
		values = new Array();
		options = new Array();
		required = false;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "field" );
		if( label != null ) x.set( "label", label );
		if( type != null ) x.set( "type", hack_enum_to.replace( Type.enumConstructor( type ), "-" ) );
		if( variable != null ) x.set( "var", variable );
		if( required ) x.addChild( XmlUtil.createElement( "required" ) );
		if( desc != null ) x.addChild( XmlUtil.createElement( "desc", desc ) );
		for( value in values ) x.addChild( XmlUtil.createElement( "value", value ) );
		for( option in options ) x.addChild( option.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Field  {
		var f = new Field();
		if( x.exists( "label" ) ) f.label = x.get( "label" );
		if( x.exists( "type" ) ) f.type = Type.createEnum( FieldType, hack_enum_from.replace ( x.get( "type" ), "_" ) );
		if( x.exists( "var" ) ) f.variable = x.get( "var" );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
				case "desc" : try { f.desc = e.firstChild().nodeValue; } catch( e : Dynamic ) {}
				case "required" : f.required = true;
				case "option" : f.options.push( FieldOption.parse( e ) );
				case "value" : try { f.values.push( e.firstChild().nodeValue ); } catch( e : Dynamic ) {}
			}
		}
		return f;
	}
	
	/**
		Parses all dataformfields into the given dataformfield container.
	*/
	public static inline function parseFields( t : { fields : Array<Field> }, x : Xml ) : { fields : Array<Field> } {
		for( e in x.elementsNamed( "field" ) ) t.fields.push( Field.parse( e.firstElement() ) );
		return t;
	}
}
