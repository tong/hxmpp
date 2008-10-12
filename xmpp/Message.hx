package xmpp;

import util.XmlUtil;


/**
	XMPP message packet.<br/>
*/
class Message extends xmpp.Packet {
	
	public static var NORMAL = "normal";
	public static var CHAT = "chat";
	public static var GROUPCHAT = "groupchat";
	public static var HEADLINE = "headline";
	public static var ERROR = "error";
	
	public var type : MessageType;
	public var subject : String;
	public var body : String;
    public var thread : String;
	

    public function new( ?type : MessageType, ?to : String, ?subject : String, ?body : String, ?thread : String, ?from : String ) {
		super( to, from );
		_type = xmpp.PacketType.message;
		this.type = if ( type != null ) type else xmpp.MessageType.normal;
		this.subject = subject;
		this.body = body;
		this.thread = thread;
	}
    
    
    public override function toXml() : Xml {
    	var xml = super.addAttributes( Xml.createElement( "message" ) );
		if( type != null ) 	  xml.set( "type", Type.enumConstructor( type ) );
		if( subject != null ) xml.addChild( XmlUtil.createElement( "subject", subject ) );
		if( body != null ) 	  xml.addChild( XmlUtil.createElement( "body", body ) );
		if( thread != null )  xml.addChild( XmlUtil.createElement( "thread", thread ) );
		return xml;
    }
    
    
    public static function parse( src : Xml ) : xmpp.Message {
    	var m = new Message( Type.createEnum( xmpp.MessageType, src.get( "type" ) ) );
   		xmpp.Packet.parseAttributes( m, src );
   		for( child in src.elements() ) {
			switch( child.nodeName ) {
				case "subject" : m.subject = child.firstChild().nodeValue;
				case "body"    : m.body = child.firstChild().nodeValue;
				case "thread"  : m.thread = child.firstChild().nodeValue;
				default 	   : m.properties.push( child );
			}
		}
   		return m;
	}
    
}
