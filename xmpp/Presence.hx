package xmpp;

import util.XmlUtil;
import xmpp.Packet;


/**
	<a href="http://xmpp.org/rfcs/rfc3921.html">RFC-3921 - Instant Messaging and Presence</a></br>
	<a href="http://www.xmpp.org/rfcs/rfc3921.html#presence">Exchanging Presence Information</a>
*/
class Presence extends Packet {
	
   	public var type : PresenceType;
   	public var show : String;
    public var status : String;
    public var priority : Null<Int>;
    
	
	public function new( ?type : PresenceType, ?show : String, ?status : String, ?priority : Int ) {
		super();
		_type = xmpp.PacketType.presence;
        this.type = type;
        this.show = show;
        this.status = status;
        this.priority = priority;
	}
	
	
	public override function toXml() : Xml {
		var xml = super.addAttributes( Xml.createElement( "presence" ) );
		if( type != null ) 					 xml.set( "type", Type.enumConstructor( type ) );
		if( show != null && show != "" ) 	 xml.addChild( XmlUtil.createElement( "show", show ) );
		if( status != null && status != "" ) xml.addChild( XmlUtil.createElement( "status", status ) );
		if( priority != null ) 				 xml.addChild( XmlUtil.createElement( "priority", Std.string( priority ) ) );
		return xml;
	}
	
	
	public static function parse( x : Xml ) : Presence {
		var p = new Presence( x.get( "type" ) );
		xmpp.Packet.parseAttributes( p, x );
		if( x.exists( "type" ) ) p.type = Type.createEnum( PresenceType, x.get( "type" ) );
		for( child in x.elements() ) {
			switch( child.nodeName ) {
				case "show" 	: p.show = child.firstChild().nodeValue;
				case "status" 	: p.status = child.firstChild().nodeValue;
				case "priority" : p.priority = Std.parseInt( child.firstChild().nodeValue );
				default 		: p.properties.push( child );
			}
		}
		return p;
	}
	
}
