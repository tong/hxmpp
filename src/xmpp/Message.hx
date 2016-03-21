package xmpp;

using xmpp.Stanza;

@:enum abstract MessageType(String) from String to String {
	var normal = "normal";
	var error = "error";
	var chat = "chat";
	var groupchat = "groupchat";
	var headline = "headline";
}

private class MessageStanza extends Stanza {

	/***/
	public var type : MessageType;

	/** Human-readable XML character data that specifies the textual contents */
    public var body : String;

	/** Human-readable XML character data that specifies the topic */
    public var subject : String;

	/** String to uniquely identify a conversation thread or "chat session" */
    public var thread : String;

	@:allow(xmpp.Message)
	function new( ?to : String, ?body : String, ?subject : String, ?type : Null<MessageType>, ?thread : String, ?from : String ) {
		super( to, from );
		this.body = body;
		this.subject = subject;
		this.type = (type != null) ? type : chat;
		this.thread = thread;
	}

	public override function toXml() : XML {
		var xml = addStanzaAttrs( XML.create( 'message' ) );
		if( type != null ) xml.set( "type", type );
		if( body != null ) xml.append( XML.create( "body", body ) );
		if( thread != null ) xml.append( XML.create( "thread", thread ) );
		for( e in properties ) xml.append( e );
		return xml;
	}
}

/**
	XMPP message stanza.

	See:
	* RFC-3921 - Instant Messaging and Presence: http://xmpp.org/rfcs/rfc3921.html
	* Exchanging Presence Information: http://www.xmpp.org/rfcs/rfc3921.html#presence
*/
@:forward(
	from,to,id,lang,
	type,
	body,subject,thread,
	properties
)
abstract Message(MessageStanza) to Stanza {

	public inline function new( ?to : String, ?body : String, ?subject : String, ?type : Null<MessageType>, ?thread : String, ?from : String )
		this = new MessageStanza( to, body, subject, type, thread, from );

	@:to public inline function toXml() : XML
		return this.toXml();

	@:to public inline function toString() : String
		return this.toString();

	@:from public static inline function fromString( str : String ) : Message
		return parse( Xml.parse( str ).firstElement() );

	@:from public static function parse( xml : XML ) : Message {
		var m = new Message( xml.get('to') ).parseAttrs( xml );
		m.type = xml.get( 'type' );
		for( e in xml.elements() ) {
			switch e.name {
			case 'subject': m.subject = e.value;
			case 'body': m.body = e.value;
			case 'thread': m.thread = e.value;
			//case 'error': //TODO
			default: m.properties.push( e );
			}
		}
		return m;
	}
}
