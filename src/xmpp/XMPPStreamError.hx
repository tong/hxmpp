package xmpp;

//TODO

class XMPPStreamError {
	
	public var condition : String;
	public var text : String;
	public var specific : Xml;
	public var lang : String;
	
	
	public function new() {
		lang = "en";
	}
	
	
	public function toXml() : Xml {
		var x = Xml.createElement( "stream:error" );
		x.set( "xmlns:stream", XMPPStream.XMLNS_STREAM );
		var c = Xml.createElement( condition );
		c.set( "xmlns", "urn:ietf:params:xml:ns:xmpp-streams" );
		x.addChild( c );
		if( text != null ) {
			var t = Xml.createElement( "text" );
			t.set( "xmlns", "urn:ietf:params:xml:ns:xmpp-streams" );
			t.set( "xml:lang", lang );
			t.addChild( Xml.createPCData( text ) );
			x.addChild( t );
		}
		if( specific != null ) x.addChild( specific );
		return x;
	}
	
	public function toString() : String {
		return toXml().toString();
	}
	
	
	public static function parse( src : Xml ) : XMPPStreamError {
		var error = new XMPPStreamError();
		var cx = src.firstChild();
		error.condition = cx.nodeName;
		var i = 0;
		for( node in src.elements() ) {
			switch( i ) {
				case 1 :
				//TODO
					//error.text = node;
				case 2 : error.specific = node;
			}
			i++;
		}
		return error;
	}
	
}
