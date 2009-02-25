package xmpp;


class StreamError {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-streams";
	
	public var condition : String;
	/** Describes the error in more detail */
	public var text : String;
	/** Language of the text content XML character data  */
	public var lang : String;
	/** Application-specific error condition */
	public var app : { condition : String, ns : String };
	
	
	public function new( ?condition : String ) {
		this.condition = condition;
	}
	
	
	public function toXml() : Xml {
		var x = Xml.createElement( "stream:error" );
		var c = Xml.createElement( condition );
		c.set( "xmlns", XMLNS );
		x.addChild( c );
		if( text != null ) {
			var t = util.XmlUtil.createElement( "text", text );
			t.set( "xmlns", XMLNS );
			if( lang != null ) t.set( "lang", lang );
			x.addChild( t );
		}
		if( app != null && app.condition != null && app.ns != null ) {
			var a = Xml.createElement( app.condition );
			a.set( "xmlns", app.ns );
			x.addChild( a );	
		}
		return x;
	}
	
	
	public static function parse( x : Xml ) : StreamError {
		var p = new StreamError();
		for( e in x.elements() ) {
			var ns = e.get( "xmlns" );
			if( ns == null ) continue;
			switch( e.nodeName ) {
			case "text" :
				if( ns == XMLNS )
					p.text = e.firstChild().nodeValue;
			default :
				if( ns == XMLNS )
					p.condition = e.nodeName;
				else
					p.app = { condition : e.nodeName, ns : ns };
			}
		}
		if( p.condition == null )
			return null;
		return p;
	}

}
