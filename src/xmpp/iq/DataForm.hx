package xmpp.iq;



enum DataFormType {
	
	/** The form-processing entity is asking the form-submitting entity to complete a form. */
	form;
	
	/** The form-submitting entity is submitting data to the form-processing entity.
		The submission MAY include fields that were not provided in the empty form,
		but the form-processing entity MUST ignore any fields that it does not understand.
	*/
	submit;
	
	/**
		The form-submitting entity has cancelled submission of data to the form-processing entity.
	*/
	cancel;
	
	/**
		The form-processing entity is returning data (e.g., search results) to the form-submitting entity,
		or the data is a generic data set.
	*/
	result;
}


class DataForm /* implements IIQExtension */ {
	
	public static inline var XMLNS = "jabber:x:data";

	
	public var type 		: DataFormType;
	public var title 		: String;
	public var instructions : Array<String>;
	public var reportedData : ReportedData;
	public var items 		: Array<DataformItem>;
	public var fields 		: Array<DataformField>;
	
	
	public function new() {
	}
	
	
	public function toXml() : Xml {
		var xml = Xml.createElement( "x" );
		xml.set( "xmlns", XMLNS );
		xml.set( "type",  );
		if( title != null ) xml.addChild( Packet.createXmlElement( "title", title ) );
		for( instruction in instructions ) xml.addChild( Packet.createXmlElement( "instructions", instruction ) );
		if( reportedData ! = null ) xml.addChild( reportedData.toXml() );
		for( item in items ) xml.addChild( item.toXml() );
		for( field in fields ) xml.addChild( field.toXml() );
		return xml;
	}
}



class DataFormReportedData extends DataFormItem {
	public function new( ?fields : Array<DataFormField> ) { super( fields ); }
	override public function toXml() : Xml { return createXml( "reported" ); }
}



class DataFormItem {
	
	public var fields : Array<DataFormField>;
	
	public function new( ?fields : Array<DataFormField> ) {
		this.fields = if( fields != null ) fields else new Array<DataFormField>();
	}
	
	public function toXml() : Xml {
		return createXml( "item" );
	}
	
	inline function createXml( name : String ) : Xml {
		var xml = Xml.createElement( name );
		for( field in fields ) xml.addChild( field.toXml() );
		return xml;
	}
}



class DataFormField {
	
	public var description 	: String;
	public var label 		: String;
	public var variable 	: String;
	public var type 		: String;
	public var options 		: Array<DataFormFieldOption>;
	public var values 		: Array<String>;
	
	public function new() {
		type = 
	}
	
	public function toXml() : Xml {
		var xml = Xml.createElement( "field" );
		if( label != null ) xml.set( "label", label );
		if( variable != null ) xml.set( "var", variable );
		if( type != null ) xml.set( "type", type );
		if( description != null ) xml.addChild( Packet.createXmlElement( "desc", description ) );
		if( required != null ) xml.addChild( Packet.createXmlElement( "required", required ) );
		for( value in values ) xml.addChild( Packet.createXmlElement( "value", value ); );	
		for( option in options ) xml.addChild( option.toXml() );	
		return xml;
	}
}



class DataFormFieldOption {
	
	public var label 		: String;
	public var value 		: String;
	
	public function new( ?label : String, ?value: String ) {
		this.label = label;
		this.value = value;
	}
	
	public function toXml() : Xml {
		var xml = Xml.createElement( "option" );
		if( label != null ) xml.set( "label", label );
		if( value != null ) xml.addChild( Packet.createXmlElement( "value", value ) );
		return xml;
	}
}
