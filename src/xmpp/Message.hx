package xmpp;

import util.XmlUtil;
import xmpp.Packet;



enum MessageType {
	normal;
	error;
	chat;
	groupchat;
	headline;
}


/**
	XMPP message packet.
*/
class Message extends Packet {
	
	//public static inline var NAME = "message";
	
	public inline static var NORMAL		= "normal";
	public inline static var CHAT		= "chat";
	public inline static var GROUPCHAT 	= "groupchat";
	public inline static var HEADLINE  	= "headline";
	public inline static var ERROR     	= "error";
	
	public var type 	: MessageType;
	public var subject 	: String;
	public var body 	: String;
    public var thread 	: String;
//	public var error 	: String;
//	public var html 	: String;

	
	public function new( ?type : MessageType, ?to : String, ?subject : String, ?body : String, ?thread : String, ?from : String ) {
		super( to, from );
		_type = PacketType.message;
		this.type = if ( type != null ) type else MessageType.normal;
		this.subject = subject;
		this.body = body;
		this.thread = thread;
	}
	
	
	override public function toXml() : Xml {
		var xml = super.addAttributes( Xml.createElement( "message" ) );
		if( type != null ) 		xml.set( "type", getMessageTypeString( type ) );
		if( subject != null ) 	xml.addChild( XmlUtil.createElement( "subject", subject ) );
		if( body != null ) 		xml.addChild( XmlUtil.createElement( "body", body ) );
//TODO	if( error != null ) 	xml.addChild( XmlUtil.createElement( "error", error ) );
//TODO	if( html != null ) 		xml.addChild( XmlUtil.createElement( "html", html ) );
		if( thread != null ) 	xml.addChild( XmlUtil.createElement( "thread", thread ) );
		return xml;
	}
	
	
	public static function parse( src : Xml ) : Message {
		var m = new Message( Message.getMessageType( src.get( "type" ) ) );
		Packet.parseAttributes( m, src );
		for( child in src.elements() ) {
			switch( child.nodeName ) {
				case "subject" 	: m.subject = child.firstChild().nodeValue;
				case "body" 	: m.body = child.firstChild().nodeValue;
				case "thread" 	: m.thread = child.firstChild().nodeValue;
				default 		: m.properties.push( child );
			}
		}
		return m;
	}
	
	
	public static function getMessageTypeString( t : MessageType ) : String {
		return switch( t ) {
			case normal 	: NORMAL;
			case chat 		: CHAT;
			case groupchat 	: GROUPCHAT;
			case headline 	: HEADLINE;
			case error 		: ERROR;
		}
	}
	
	public static function getMessageType( p : String ) : MessageType {
		return switch( p ) {
			case NORMAL 	: normal;
			case CHAT 		: chat;
			case GROUPCHAT 	: groupchat;
			case HEADLINE 	: headline;
			case ERROR 		: error;
		}
	}
	
}
