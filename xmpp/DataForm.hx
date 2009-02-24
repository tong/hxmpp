package xmpp;

import util.XmlUtil;
import xmpp.dataform.FormType;


/**
	DataForm packet extension (for iq and message packets).
	<a href="http://xmpp.org/extensions/xep-0004.html">XEP-0004: Data Forms</a><br/>
*/
class DataForm {
	
	public static var XMLNS = "jabber:x:data";
	
	public var type : FormType;
	public var title : String;
	public var instructions : String;
	public var fields : Array<xmpp.dataform.Field>;
	public var reported : xmpp.dataform.Reported;
	public var items : Array<xmpp.dataform.Item>;
	
	
	public function new( ?type : FormType ) {
		this.type = type;
		fields = new Array();
		items = new Array();
	}
	
	
	public function toXml() : Xml {
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
	
	public inline function toString() : String { return toXml().toString(); }
	
	
	public static function parse( x : Xml ) : DataForm {
		var f = new DataForm();
		f.type = Type.createEnum( xmpp.dataform.FormType, x.get( "type" ) );
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "title" : f.title = e.firstChild().nodeValue;
			case "field" : f.fields.push( xmpp.dataform.Field.parse( e ) );
			case "item" : f.items.push( xmpp.dataform.Item.parse( e ) );
			case "instructions" : f.instructions = e.firstChild().nodeValue;
			case "reported" : f.reported = xmpp.dataform.Reported.parse( e );
			}
		}
		return f;
	}
	
}
