package xmpp;

import util.XmlUtil;


/**
	XMPP message packet.
*/
class Message extends xmpp.Packet {
	
	public var type : MessageType;
	public var subject : String; //PacketElement TODO
	public var body : String; //PacketElement TODO
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
    	var x = super.addAttributes( Xml.createElement( "message" ) );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		if( subject != null ) x.addChild( XmlUtil.createElement( "subject", subject ) );
		if( body != null ) x.addChild( XmlUtil.createElement( "body", body ) );
		if( thread != null ) x.addChild( XmlUtil.createElement( "thread", thread ) );
		for( p in properties ) {
			x.addChild( p );
		}
		return x;
    }
    
    
    public static function parse( x : Xml ) : xmpp.Message {
    	var m = new Message( if( x.exists( "type" ) ) Type.createEnum( xmpp.MessageType, x.get( "type" ) ) );
   		//Packet.parsePacketBase( m, x );
   		Packet.parseAttributes( m, x );
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
