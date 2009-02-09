package xmpp;

import util.XmlUtil;


/**
	XMPP message packet.
*/
class Message extends xmpp.Packet {
	
	public var type : MessageType;
	public var body : String;
	public var subject : String;
    public var thread : String;
	

    public function new( ?to : String, ?body : String, ?subject : String,
    					 ?type : MessageType, ?thread : String, ?from : String ) {
    					 	
		_type = xmpp.PacketType.message;
		
		super( to, from );
		this.type = if ( type != null ) type else xmpp.MessageType.normal;
		this.body = body;
		this.subject = subject;
		this.thread = thread;
	}
    
    
    public override function toXml() : Xml {
    	var x = super.addAttributes( Xml.createElement( "message" ) );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		if( subject != null ) x.addChild( XmlUtil.createElement( "subject", subject ) );
		if( body != null ) x.addChild( XmlUtil.createElement( "body", body ) );
		if( thread != null ) x.addChild( XmlUtil.createElement( "thread", thread ) );
		for( p in properties ) x.addChild( p );
		return x;
    }
    
    
    public static function parse( x : Xml ) : xmpp.Message {
    	var m = new Message( null, null, null, if( x.exists( "type" ) ) Type.createEnum( xmpp.MessageType, x.get( "type" ) ) );
   		//Packet.parsePacketBase( m, x );
   		xmpp.Packet.parseAttributes( m, x );
   		for( c in x.elements() ) {
			switch( c.nodeName ) {
				case "subject" : m.subject = c.firstChild().nodeValue;
				case "body" : m.body = c.firstChild().nodeValue;
				case "thread" : m.thread = c.firstChild().nodeValue;
				default : m.properties.push( c );
			}
		}
   		return m;
	}
    
}
