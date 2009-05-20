package xmpp;

/**
	<a href="http://www.xmpp.org/extensions/xep-0202.html">XEP 202 - EntityTime</a>
*/
class EntityTime {
	
	public static var XMLNS = "urn:xmpp:time";
	
	/**
		The entity's numeric time zone offset from UTC.
		The format conforms to the Time Zone Definition (TZD) specified in XEP-0082 (http://www.xmpp.org/extensions/xep-0082.html).
	*/
	public var tzo : String;// (default,setTZO) : String;
	
	/**
		 The UTC time according to the responding entity.
		 The format conforms to the dateTime profile specified in XEP-0082 (http://www.xmpp.org/extensions/xep-0082.html)
		 and MUST be expressed in UTC.
	*/
	public var utc : String; // (default,setUTC) : String;
	
	
	public function new( ?tzo : String, ?utc : String ) {
		this.tzo = tzo;
		this.utc = utc;	
	}
	
/*
	function setTZO( t : String ) : String {
		//if( !xmpp.DateTime.isValid( t ) ) return tzo = null;
		return tzo = t;
	}
	function setUTC( t : String ) : String {
		if( !xmpp.DateTime.isValid( t ) ) return utc = null;
		return utc = t;
	}
	*/
	
	public function toXml() : Xml {
		var x = Xml.createElement( "time" );
		x.set( "xmlns", XMLNS );
		if( tzo != null ) x.addChild( util.XmlUtil.createElement( "tzo", tzo ) );
		if( utc != null ) x.addChild( util.XmlUtil.createElement( "utc", utc ) );
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	public static function parse( x : Xml ) : xmpp.EntityTime {
		var t = new EntityTime();
		for( c in x.elements() ) {
			switch( c.nodeName ) {
			case "tzo" : t.tzo = c.firstChild().nodeValue;
			case "utc" : t.utc = c.firstChild().nodeValue;
			}
		}
		return t;
	}
	
}
