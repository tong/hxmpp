package xmpp;

class Jingle {
	
	public static var XMLNS = "urn:xmpp:jingle:1";
	public static var NODENAME = "jingle";
	
	public var action : xmpp.jingle.Action;
	public var initiator : String;
	public var sid : String;
	public var responder : String;
	public var content : Array<xmpp.jingle.Content>;
//	public var reason : xmpp.jingle.Reason;
//	public var thread : Thread;
	public var any : Array<Xml>;

	public function new( action : xmpp.jingle.Action, initiator : String, sid : String ) {
		this.action = action;
		this.initiator = initiator;
		this.sid = sid;
		content = new Array();
		any = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( NODENAME );
		x.set( "xmlns", XMLNS );
		x.set( "action", StringTools.replace( Type.enumConstructor( action ), "_", "-" ) );
		x.set( "initiator", initiator );
		x.set( "sid", sid );
		if( responder != null ) x.set( "responder", responder );
		for( c in content )
			x.addChild( c.toXml() );
		for( a in any )
			x.addChild( a );
		//TODO
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.Jingle {
		var j = new xmpp.Jingle( Type.createEnum( xmpp.jingle.Action, StringTools.replace( x.get( "action" ), "-", "_" ) ), x.get( "initiator" ), x.get( "sid" )  );
		//TODO
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "content" :
				j.content.push( xmpp.jingle.Content.parse( e ) );
			//case "reason" :
			default :
				j.any.push( e );
			}
		}
		return j;
	}
	
	//public static function createTransport( xmlns : String, e : Array<Xml> )
}
