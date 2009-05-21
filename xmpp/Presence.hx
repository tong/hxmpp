package xmpp;

import util.XmlUtil;

/**
	<a href="http://xmpp.org/rfcs/rfc3921.html">RFC-3921 - Instant Messaging and Presence</a></br>
	<a href="http://www.xmpp.org/rfcs/rfc3921.html#presence">Exchanging Presence Information</a>
*/
class Presence extends Packet {
	
   	public var type : PresenceType;
   	public var show : String;
    public var status(default,setStatus) : String;
    public var priority : Null<Int>;
    
	public function new( ?type : PresenceType, ?show : String, ?status : String, ?priority : Int ) {
		super();
		_type = xmpp.PacketType.presence;
		this.type = type;
		this.show = show;
		this.status = status;
		this.priority = priority;
	}
	
	function setStatus( s : String ) : String {
		if( s == null ) return status = s;
		if( s.length > 1023 || s.length == 0 ) throw "Invalid presence status size";
		return status = s;
	}
	
	public override function toXml() : Xml {
		var x = super.addAttributes( Xml.createElement( "presence" ) );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		if( show != null && show != "" ) x.addChild( XmlUtil.createElement( "show", show ) );
		if( status != null && status != "" ) x.addChild( XmlUtil.createElement( "status", status ) );
		if( priority != null ) x.addChild( XmlUtil.createElement( "priority", Std.string( priority ) ) );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.Presence {
		var p = new Presence( x.get( "type" ) );
		xmpp.Packet.parseAttributes( p, x );
		if( x.exists( "type" ) ) p.type = Type.createEnum( PresenceType, x.get( "type" ) );
		for( c in x.elements() ) {
			var n = c.firstChild();
			if( n != null ) {
				switch( c.nodeName ) {
				case "show" : p.show = c.firstChild().nodeValue;
				case "status" : p.status = c.firstChild().nodeValue;
				case "priority" : p.priority = Std.parseInt( c.firstChild().nodeValue );
				default : p.properties.push( c );
				}
			}
		}
		return p;
	}
	
}
