package xmpp;

//TODO VCard4
// parsing is half complete
// toXml

using xmpp.VCardBase;

typedef Name = {
	?family : String,
	?given : String,
	?middle : String,
	?prefix : String,
	?suffix : String,
	?surname : String // ?? missing in spec xslt
}

typedef Photo = {
	ext : String,
	type : String
}

/**
	VCard(4), obsoletes VCardTemp.

	<a href="http://www.xmpp.org/extensions/xep-0292.html">XEP-0292: vCard4</a>
	<a href="http://tools.ietf.org/html/rfc6350">RFC 6350</a>
	<a href="http://tools.ietf.org/html/rfc6351">RFC 6351</a>
*/
class VCard extends VCardBase {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:vcard-4.0";
	
	public var fn : String;
	public var n : Name;
	public var nickname : Array<String>;
	//public var photo : Array<Photo>;
	public var bday : String;
	//public var adr : Array<Adr>;
	//public var tel : Array<Tel>;
	//public var email : Array<Email>;
	public var title : Array<String>;
	public var role : Array<String>;
	public var geo : Array<String>;
	public var url : Array<String>;
	public var note : Array<String>;
	public var prodid : String;
	public var impp : String;
	public var key : Array<String>;
	public var org : Array<String>;
	public var logo : Array<String>;
	
	public function new() {
		super( XMLNS );
		nickname = new Array();
		//photo = new Array();
		role = new Array();
		title = new Array();
		geo = new Array();
		url = new Array();
		note = new Array();
		key = new Array();
		org = new Array();
		logo = new Array();
	}
	
	//TODO
	public override function toXml() : Xml {
		var x = emptyXml();
		//addXmlField( x, "fn" );
		//addXmlField( x, "birthday" );
		//addXmlFields( x, "url" );
		return x;
	}
	
	public static function emptyXml() : Xml {
		var x = Xml.createElement( "vcard" );
		x.set( "xmlns", XMLNS );
		return x;
	}
	
	public static function parse( x : Xml ) : VCard {
		var vc = new VCard();
		for( e in x.elements() ) {
			//trace(e.nodeName.toLowerCase());
			switch( e.nodeName.toLowerCase() ) {
			case "fn" : vc.fn = e.parseTextValue();
			case "n" :
				vc.n = cast {};
				e.reflectElementValues( vc.n );
			case "nickname" : vc.nickname.push( e.parseTextValue() );
			case "photo" :
				//TODO trace("TODOOOOOOOOO");
			case "bday" : vc.bday = e.parseTextValue();
			case "adr" :
				//TODO
			//...
			
			case "role" : vc.role.push( e.parseTextValue() );
			case "title" : vc.title.push( e.parseTextValue() );
			case "geo" : vc.geo.push( e.parseTextValue() );
			case "url" : vc.url.push( e.parseTextValue() );
			case "note" : vc.note.push( e.parseTextValue() );
			case "prodid" : vc.prodid = e.parseTextValue();
			case "impp" : vc.impp = e.parseTextValue();
			case "key" : vc.key.push( e.parseTextValue() );
			case "org" : vc.org.push( e.parseTextValue() );
			case "logo" : vc.logo.push( e.parseTextValue() );
			
			}
			
		}
		return vc;
	}
	
}
	