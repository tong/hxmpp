package xmpp;

//TODO VCard4

typedef Name = {
	var family : String;
	var given : String;
	var middle : String;
	var prefix : String;
	var suffix : String;
}

/**
	<a href="http://www.xmpp.org/extensions/xep-0292.html">XEP-0292: vCard4</a>
	<a href="http://tools.ietf.org/html/rfc6350">RFC 6350</a>
	<a href="http://tools.ietf.org/html/rfc6351">RFC 6351</a>

	Obsoletes VCardTemp.
*/
class VCard {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:vcard-4.0";
	
	public var fn : String; // required
	public var n : xmpp.vcard.Name; // required
	
	/*
	public var nickname : String;
	public var photo : Photo;
	public var bday : String;
	public var tel : Array<String>;
	public var email : Array<String>;
	public var jid : Array<String>;
	public var tz : Array<String>;
	public var geo : Array<String>;
	public var title : Array<String>;
	public var role : Array<String>;
	public var logo : Array<Logo>;
	public var agent : Array<>;
	public var org : Array<>;
	public var categories : Array<>;
	public var note : Array<>;
	public var prodid : String;
	public var timestap : String;
	public var sort_string : String;
	public var sound : Array<>;
	public var uid : String;
	public var url : Array<>;
	public var key : Array<>;
	public var desc : Array<>;
	*/
	
	public function new() {
	}
	
	public function toXml() : Xml {
		var x = emptyXml();
		addXmlField( "fn", x );
		addXmlField( "birthday", x );
		addXmlFields( "url", x );
		return x;
	}
	
	function addXmlField( n : String, x : Xml, ?name : String ) {
		var v = Reflect.field( this, n );
		if( v != null )
			x.addChild( XMLUtil.createElement( (name==null) ? n : name, v ) );
	}
	
	function addXmlFields( id : String, x : Xml ) {
		var field = Reflect.field( this, id );
		if( field != null ) {
			for( f in Reflect.fields( field ) ) {
				var v = Reflect.field( field, f );
				if( v != null ) {
					
				}
				/*
				var v = Reflect.field( f, f) );
				if( f != null ) {
					
				}
				*/
			}
		}
	}
	
	/**
	*/
	public static function emptyXml() : Xml {
		var x = Xml.createElement( "vcard" );
		x.set( "xmlns", XMLNS );
		//#if flash x.set( "_xmlns_", XMLNS ); #else x.set( "xmlns", XMLNS ); #end // TODO haxe 2.06
		return x;
	}
	
	/**
	*/
	public static function parse( x : Xml ) : VCard {
		var vc = new VCard();
		for( e in x.elements() ) {
			trace(e.nodeName );
		}
		return vc;
	}
	
}
	