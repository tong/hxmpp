package xmpp;

import xmpp.Packet;


//TODO presence mode


class Presence extends Packet {
	
	public static inline var AVAILABLE 		= "available";
	public static inline var OFFLINE 		= "offline";
	public static inline var AWAY 			= "away";
	public static inline var XA 			= "xa";
	public static inline var CHAT			= "chat";
	public static inline var DND 			= "dnd";
	public static inline var UNAVAILABLE 	= "unavailable";
	public static inline var SUBSCRIBE	 	= "subscribe";
	public static inline var SUBSCRIBED		= "subscribed";
	public static inline var UNSUBSCRIBED 	= "unsubscribed";

	
   	public var type 	: String;
   	public var show 	: String;
    public var status 	: String;
    public var priority : Null<Int>;
    
	
	public function new( ?type : String, ?show : String, ?status : String, ?priority : Int ) {
		super();
		_type = PacketType.presence;
        this.type = type;
        this.show = show;
        this.status = status;
        this.priority = priority;
	}
	
	
	override public function toXml() : Xml {
		var xml = super.addAttributes( Xml.createElement( "presence" ) );
		if( type != null ) 						xml.set( "type", type );
		if( show != null && show != "" ) 		xml.addChild( Packet.createXmlElement( "show", show ) );
		if( status != null && status != "" ) 	xml.addChild( Packet.createXmlElement( "status", status ) );
		if( priority != null ) 					xml.addChild( Packet.createXmlElement( "priority", Std.string( priority ) ) );
		return xml;
	}
	
	
	public static function parse( x : Xml ) : Presence {
		var p = new Presence( x.get( "type" ) );
		Packet.parseAttributes( p, x );
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
	
	
	/*
	public static function getPresenceTypeString( p : PresenceType ) : String {
		return switch( p ) {
			case error 		: ERROR;
			case available 		: AVAILABLE;
			case offline 		: OFFLINE;
			case away 			: AWAY;
			case xa 			: XA;
			case chat 			: CHAT;
			case dnd 			: DND;
			case unavailable 	: UNAVAILABLE;
			case subscribe 		: SUBSCRIBE;
			case subscribed 	: SUBSCRIBED;
			case unsubscribed 	: UNSUBSCRIBED;
		}
	}
	
	public static function getPresenceType( p : String ) : PresenceType {
		return switch( p ) {
			case ERROR 		: error;
			case AVAILABLE 		: available;
			case OFFLINE 		: offline;
			case AWAY 			: away;
			case XA 			: xa;
			case CHAT 			: chat;
			case DND 			: dnd;
			case UNAVAILABLE 	: unavailable;
			case SUBSCRIBE 		: subscribe;
			case UNSUBSCRIBED 	: unsubscribed;
		}
	}
	*/
}
