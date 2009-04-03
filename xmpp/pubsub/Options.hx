package xmpp.pubsub;

class Options {
	
	public var jid : String;
	public var node : String;
	public var subid : String;
	public var form : xmpp.DataForm;
	
	public function new( jid : String, ?node : String, ?subid : String, ?form : xmpp.DataForm ) {
		this.jid = jid;
		this.node = node;
		this.subid = subid;
		this.form = form;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "options" );
		if( node != null ) x.set( "node", node );
		if( subid != null ) x.set( "subid", subid );
		if( form != null ) x.addChild( form.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Options {
		//var f = if( x.elementsNamed( "x" ) != null ) xmpp.DataForm.parse( ) else null;
		var f : xmpp.DataForm = null;
		for( e in x.elementsNamed("x") ) {
			f = xmpp.DataForm.parse( e );
			break;
		}
		return new Options( x.get( "jid" ),  x.get( "node" ),  x.get( "subid" ), f );
	}
	
}
