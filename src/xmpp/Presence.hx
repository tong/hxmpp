package xmpp;

using xmpp.Stanza;

/**
	Optional <show/> element specifying the particular availability sub-state of an entity or a specific resource thereof.

	http://xmpp.org/rfcs/rfc6121.html#presence-syntax-children-show
*/
@:enum abstract PresenceShow(String) from String to String {

	/** Especially socialable */
	var chat = "chat";

	/** Away from device */
	var away = "away";

	/** Extended Away */
	var xa = "xa";

	/** Busy */
	var dnd = "dnd";
}

/**
	The absence of a 'type' attribute signals that the relevant entity is available for communication.
	A 'type' attribute with a value of "unavailable" signals that the relevant entity is not available for communication.

	Note: There is no default value for the 'type' attribute of the <presence/> element.
	Note: There is no value of "available" for the 'type' attribute of the <presence/> element.

	http://xmpp.org/rfcs/rfc6121.html#presence-syntax-type
*/
@:enum abstract PresenceType(String) from String to String {

	/** An error has occurred regarding processing or delivery of a previously-sent presence stanza. */
	var error = "error";

	/** A request for an entity's current presence; SHOULD be generated only by a server on behalf of a user. */
	var probe = "probe";

	/** The sender wishes to subscribe to the recipient's presence. */
	var subscribe = "subscribe";

	/** The sender has allowed the recipient to receive their presence. */
	var subscribed = "subscribed";

	/** Signals that the entity is no longer available for communication. */
	var unavailable = "unavailable";

	/** The sender is unsubscribing from another entity's presence. */
	var unsubscribe = "unsubscribe";

	/** The subscription request has been denied or a previously-granted subscription has been cancelled. */
	var unsubscribed = "unsubscribed";
}

/**
	Optional <status/> element containing human-readable XML character data specifying a natural-language description of an entity's availability.
	It is normally used in conjunction with the show element to provide a detailed description of an availability state (e.g., "In a meeting") when the presence stanza has no 'type' attribute.

	http://xmpp.org/rfcs/rfc6121.html#presence-syntax-children-status
*/
abstract PresenceStatus(String) from String to String {

	public inline function new( s : String ) this = s;

	@:to public inline function toXml() : Xml
		return XML.create( "status", this );

	@:from public static inline function fromXml( xml : XML ) : PresenceStatus
		return new PresenceStatus( xml.value );
}

/**
	Optional <priority/> element containing non-human-readable XML character data that specifies the priority level of the resource.
	The value MUST be an integer between -128 and +127.

	http://xmpp.org/rfcs/rfc6121.html#presence-syntax-children-priority
*/
abstract PresencePriority(Int) from Int to Int {

	@:noCompletion public inline function new( i : Int ) this = i;

	@:to public inline function toXml() : XML {
		return XML.create( "priority", Std.string( this ) );
	}

	//@:from public static inline function fromInt( i : Int ) : PresencePriority
	//	return new PresencePriority( i );

	@:from public static inline function fromString( s : String ) : PresencePriority
		return new PresencePriority( Std.parseInt( s ) );

	@:from public static inline function fromXml( xml : XML ) : PresencePriority
		return new PresencePriority( fromString( xml.value ) );
}

/**
	Roster subscription states.
*/
@:enum abstract PresenceSubscription(String) from String to String {

	/** The user and subscriber have no interest in each other's presence. */
	var none = "none";

	/** The user is interested in receiving presence updates from the subscriber. */
	var to = "to";

	/** The subscriber is interested in receiving presence updates from the user. */
	var from = "from";

	/** The user and subscriber have a mutual interest in each other's presence. */
	var both = "both";

	/** The user wishes to stop receiving presence updates from the subscriber. */
	var remove = "remove";
}

private class PresenceStanza extends Stanza {

	public var type : PresenceType;
	public var show : PresenceShow;
	public var status : String;
	public var priority : Null<PresencePriority>;

	public function new( ?show : PresenceShow, ?status : String, ?priority : PresencePriority, ?type : PresenceType ) {
        super();
		this.show = show;
		this.status = status;
		this.priority = priority;
		this.type = type;
	}

	public override function toXml() : XML {
		var xml = addStanzaAttrs( XML.create( 'presence' ) );
		if( type != null ) xml.set( "type", type );
		if( show != null ) xml.append( XML.create( "show", show ) );
		if( status != null ) xml.append( XML.create( "status", status ) );
		if( priority != null ) xml.append( priority );
		return xml;
	}

	/*
	public static inline function parse( xml : XML ) : PresenceStanza {
		var p = new PresenceStanza( xml.get( "type" ) );
		p.to = xml.get( 'to' );
		p.from = xml.get( 'from' );
		p.id = xml.get( 'id' );
		p.lang = xml.get( 'lang' );
		for( e in xml.elements() ) {
			switch e.name {
			case 'show':
			case 'status': p.status = e.value;
			case 'priority': p.priority = e.value;
			case 'error':
			}
		}
		return p;
	}
	*/
}

/**
	XMPP presence stanza.

	RFC-3921 - Instant Messaging and Presence: http://xmpp.org/rfcs/rfc3921.html
	Exchanging Presence Information: http://www.xmpp.org/rfcs/rfc3921.html#presence
*/
@:forward(
	from,to,id,lang,
	show,status,priority,type
)
abstract Presence(PresenceStanza) to Stanza {

	public inline function new( ?show : PresenceShow, ?status : String, ?priority : PresencePriority, ?type : PresenceType )
		this = new PresenceStanza( show, status, priority, type );

	@:to public inline function toXml() : XML
		return this.toXml();

	@:to public inline function toString() : String
		return this.toString();

	@:from public static inline function fromString( str : String ) : Presence
		return parse( Xml.parse( str ).firstElement() );

	@:from public static function parse( xml : XML ) : Presence {
		var p = new Presence().parseAttrs( xml );
		p.type = xml.get( 'type' );
		for( e in xml.elements() ) {
			switch e.name {
			case 'show': p.show = e.value;
			case 'status': p.status = e.value;
			case 'priority': p.priority = e.value;
			case 'error': //TODO
			}
		}
		return p;
	}
}
