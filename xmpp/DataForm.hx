package xmpp;

import util.XmlUtil;


enum DataFormType {
	cancel;
	form;
	result;
	submit;
}


enum DataFormFieldType {
	boolean;
	fixed;
	hidden;
	jid_multi;
	jid_single;
	list_multi;
	list_single;
	text_multi;
	text_private;
	text_single;
}


class DataFormFieldOption {
	
	public var label : String;
	public var value : String;
	
	public function new( ?label : String, ?value: String ) {
		this.label = label;
		this.value = value;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "option" );
		if( label != null ) x.set( "label", label );
		if( value != null ) x.addChild( XmlUtil.createElement( "value", value ) );
		return x;
	}
	
	public static function parse( x : Xml ) : DataFormFieldOption {
		var option = new DataFormFieldOption();
		option.label = x.get( "label" );
		option.value = x.elements().next().firstChild().nodeValue;
		return option;
	}
}


class DataFormField {
	
	// dirty hack for the enums.
	static inline var hack_enum_from = ~/-/;
	static inline var hack_enum_to = ~/_/;
	
	public var label : String;
	public var type : DataFormFieldType;
	public var variable : String;
	public var desc : String;
	public var required : Bool;
	public var values : Array<String>;
	public var options : Array<DataFormFieldOption>;
	
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
	
	public static function parse( x : Xml ) : DataFormField  {
		var field = new DataFormField();
		if( x.exists( "label" ) ) field.label = x.get( "label" );
		if( x.exists( "type" ) ) field.type = Type.createEnum( DataFormFieldType, hack_enum_from.replace ( x.get( "type" ), "_" ) );
		if( x.exists( "var" ) ) field.variable = x.get( "var" );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
				case "desc" : try { field.desc = e.firstChild().nodeValue; } catch( e : Dynamic ) {}
				case "required" : field.required = true;
				case "option" : field.options.push( DataFormFieldOption.parse( e ) );
				case "value" : try { field.values.push( e.firstChild().nodeValue ); } catch( e : Dynamic ) {}
			}
		}
		return field;
	}
	
	/**
		Parses all dataformfields into the given dataformfield container.
	*/
	public static inline function parseFields( t : { fields : Array<DataFormField> }, x : Xml ) : { fields : Array<DataFormField> } {
		for( e in x.elementsNamed( "field" ) ) t.fields.push( DataFormField.parse( e.firstElement() ) );
		return t;
	}
}



class DataFormItem {
	
	public var fields : Array<DataFormField>;
	
	public function new( ?fields : Array<DataFormField> ) {
		this.fields = if( fields != null ) fields else new Array<DataFormField>();
	}
	
	public function toXml() : Xml {
		return createXml( "item" );
	}
	
	inline function createXml( n : String ) : Xml {
		var x = Xml.createElement( n );
		for( f in fields ) x.addChild( f.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : DataFormItem {
		return cast DataFormField.parseFields( new DataFormItem(), x );
	}
}



class DataFormReported extends DataFormItem {
	
	public function new( ?fields : Array<DataFormField> ) {
		super( fields );
	}
	
	public override function toXml() : Xml {
		return createXml( "reported" );
	}
	
	public static function parse( x : Xml ) : DataFormReported {
		return cast DataFormField.parseFields( new DataFormReported(), x );
	}
}


/**
	DataForm packet extension (for iq and message packets).
	
	<a href="http://xmpp.org/extensions/xep-0004.html">XEP-0004: Data Forms</a><br/>
	
*/
class DataForm {
	
	public static var XMLNS = "jabber:x:data";
	
	public var type : DataFormType;
	public var title : String;
	public var instructions : String;
	public var fields : Array<DataFormField>;
	public var reported : DataFormReported;
	public var items : Array<DataFormItem>;
	
	
	public function new( ?type : DataFormType ) {
		this.type = type;
		fields = new Array();
		items = new Array();
	}
	
	
	public function toXml() : Xml {
		//TODO validate
		var x = Xml.createElement( "x" );
		x.set( "xmlns", XMLNS );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		if( title != null ) x.addChild( XmlUtil.createElement( "title", title ) );
		if( instructions != null ) x.addChild( XmlUtil.createElement( "instructions", instructions ) );
		for( f in fields ) x.addChild( f.toXml() );
		if( reported != null ) x.addChild( reported.toXml() );
		for( i in items ) x.addChild( i.toXml() ); 
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	
	public static function parse( x : Xml ) : DataForm {
		
		var f = new haxe.xml.Fast( x );
		if( !f.has.xmlns || !f.has.type ) return null;
		
		var form = new DataForm();
		form.type = Type.createEnum( DataFormType, f.att.type );
		if( f.hasNode.title ) form.title = f.node.title.innerData;
		if( f.hasNode.instructions ) form.instructions = f.node.instructions.innerData;
		for( field in f.nodes.field ) form.fields.push( DataFormField.parse( field.x ) );
		for( item in f.nodes.item ) form.items.push( DataFormItem.parse( item.x ) );
		if( f.hasNode.reported ) form.reported = DataFormReported.parse( f.node.reported.x );
		return form;
	}
	
}
