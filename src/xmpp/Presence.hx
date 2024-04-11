package xmpp;

using xmpp.Stanza;

enum abstract Show(String) to String {
	/** Especially socialable **/
	var chat;

	/** Away from device **/
	var away;

	/** Extended Away **/
	var xa;

	/** Busy (do not disturb) **/
	var dnd;

	// @:from public static inline function fromString(s:String)
	// 	return switch s {
	// 		case 'chat': chat;
	// 		case 'away': away;
	// 		case 'xa': xa;
	// 		case 'dnd': dnd;
	// 		case _: null;
	// 	}
}

enum abstract PresenceType(String) to String {
	/** An error has occurred regarding processing or delivery of a previously-sent presence stanza. **/
	var error;

	/** A request for an entity's current presence; SHOULD be generated only by a server on behalf of a user. **/
	var probe;

	/** The sender wishes to subscribe to the recipient's presence. **/
	var subscribe;

	/** The sender has allowed the recipient to receive their presence. **/
	var subscribed;

	/** Signals that the entity is no longer available for communication. **/
	var unavailable;

	/** The sender is unsubscribing from another entity's presence. **/
	var unsubscribe;

	/** The subscription request has been denied or a previously-granted subscription has been cancelled. **/
	var unsubscribed;

	@:from public static inline function fromString(s:String):PresenceType {
		return switch s {
			case 'error': error;
			case 'probe': probe;
			case 'subscribe': subscribe;
			case 'unavailable': unavailable;
			case 'unsubscribe': unsubscribe;
			case 'unsubscribed': unsubscribed;
			case null, _: null;
		}
	}
}

abstract Status(String) from String to String {
	@:noCompletion public inline function new(s:String)
		this = s;

	@:to public inline function toXML():XML
		return XML.create("status", this);

	@:from public static inline function fromXML(xml:XML):Status
		return new Status(xml.text);
}

abstract Priority(Int) from Int to Int {
	public static inline var MIN = -128;
	public static inline var MAX = 127;

	@:noCompletion public function new(i:Int)
		this = i < MIN ? MIN : i > MAX ? MAX : i;

	@:to public inline function toXML():XML
		return XML.create("priority", Std.string(this));

	@:from public static inline function fromFloat(f:Float)
		return new Priority(Std.int(f));

	@:from public static inline function fromString(s:String)
		return new Priority(Std.parseInt(s));

	@:from public static inline function fromXML(x:XML)
		return new Priority(fromString(x.text));
}

/**
	Presence subscription states.
**/
enum abstract Subscription(String) from String to String {
	/** The user and subscriber have no interest in each other's presence. */
	var none;

	/** The user is interested in receiving presence updates from the subscriber. */
	var to;

	/** The subscriber is interested in receiving presence updates from the user. */
	var from;

	/** The user and subscriber have a mutual interest in each other's presence. */
	var both;

	/** The user wishes to stop receiving presence updates from the subscriber. */
	var remove;

	@:from public static inline function fromString(s:String)
		return switch s {
			case 'none': none;
			case 'to': to;
			case 'from': from;
			case 'both': both;
			case 'remove': remove;
			case null, _: null;
		}
}

/**
	XMPP presence stanza.

	The `<presence/>` element represents a broadcast or *publish-subscribe* mechanism, whereby multiple entities receive information about an entity to which they have subscribed (in this case, network availability information).

	@see https://xmpp.org/rfcs/rfc3921.html>
**/
@:forward(from, to, id, lang, error, type, show, status, priority, properties)
abstract Presence(PresenceStanza) to Stanza {
	public static inline var NAME = 'presence';

	public inline function new(?show:Show, ?status:Status, ?priority:Priority, ?type:PresenceType)
		this = new PresenceStanza(show, status, priority, type);

	@:to public inline function toXML():XML
		return this.toXML();

	@:to public inline function toString():String
		return this.toString();

	@:from public static inline function fromString(str:String):Presence
		return fromXML(XML.parse(str).firstElement);

	@:from public static inline function fromXML(xml:XML):Presence
		return PresenceStanza.parse(xml);
}

private class PresenceStanza extends Stanza {
	/**
		The absence of a `type` attribute signals that the relevant entity is available for communication.
		A `type` attribute with a value of *unavailable* signals that the relevant entity is not available for communication.

		Note:
			- There is no default value for the `type` attribute of the `<presence/>` element.
			- There is no value of *available* for the `type` attribute of the `<presence/>` element.

		@see <https://xmpp.org/rfcs/rfc6121.html#presence-syntax-type>
	**/
	public var type:PresenceType;

	/**
		Optional `<show/>` element specifying the particular availability sub-state of an entity or a specific resource thereof.

		@see https://xmpp.org/rfcs/rfc6121.html#presence-syntax-children-show
	**/
	public var show:Show;

	/**
		Optional `<status/>` element containing human-readable XML character data specifying a natural-language description of an entity's availability.
		It is normally used in conjunction with the show element to provide a detailed description of an availability state (e.g., "In a meeting") when the presence stanza has no `type` attribute.

		@see https://xmpp.org/rfcs/rfc6121.html#presence-syntax-children-status
	**/
	public var status:Status;

	/**
		Optional `<priority/>` element containing non-human-readable XML character data that specifies the priority level of the resource. The value MUST be an integer between `-128` and `+127`.

		@see <https://xmpp.org/rfcs/rfc6121.html#presence-syntax-children-priority>
	**/
	public var priority:Null<Priority>;

	public function new(?show:Show, ?status:String, ?priority:Priority, ?type:PresenceType) {
		super();
		this.show = show;
		this.status = status;
		this.priority = priority;
		this.type = type;
	}

	public function toXML():XML {
		final xml = Stanza.createXML(this, Presence.NAME);
		if (type != null)
			xml.set("type", type);
		if (show != null)
			xml.append(XML.create("show", show));
		if (status != null)
			xml.append(XML.create("status", status));
		if (priority != null)
			xml.append(priority);
		for (p in properties)
			xml.append(p);
		return xml;
	}

	public static function parse(xml:XML):Presence {
		final p = Stanza.parseAttributes(new Presence(), xml);
		p.type = xml.get('type');
		for (e in xml.elements) {
			switch e.name {
				case 'show':
					p.show = cast e.text;
				case 'status':
					p.status = Std.string(e.text);
				case 'priority':
					p.priority = try Std.parseInt(e.text) catch (e) null;
				case 'error':
					p.error = e;
				default:
					p.properties.push(e);
			}
		}
		return p;
	}
}
