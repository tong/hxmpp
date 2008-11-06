package xmpp;


/**
	Holds static methods for creation of xml data required for SASL authetication.
*/
class SASL {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-sasl";
	
	/**
	*/
	public static function createAuthXml( mechansim : String, ?text : String ) : Xml {
		if( mechansim == null ) return null;
		var a = ( text == null ) ? Xml.createElement( "auth" ) : util.XmlUtil.createElement( "auth", text );
		a.set( "xmlns", XMLNS );
		a.set( "mechanism", mechansim );
		return a;
	}
	
	/**
	*/
	public static function createResponseXml( content : String ) : Xml {
		if( content == null ) return null;
		var r = util.XmlUtil.createElement( "response", content );
		r.set( "xmlns", XMLNS );
		return r;
	}
	
	/**
	*/
	public static function parseMechanisms( x : Xml ) : Array<String> {
		var m = new Array<String>();
		for( e in x.elements() ) {
			if( e.nodeName != "mechanism" ) continue;
			m.push( e.firstChild().nodeValue );
		}
		return m;
	}
	
}
