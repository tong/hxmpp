package xmpp.client;

import xmpp.IQ;
import xmpp.Presence;

/**
	Pending state of a subscription request of a roster item.
**/
enum abstract AskType(String) from String to String {
	/** A request to subscribe to the contact's presence has been sent and is pending. **/
	var subscribe;

	/** Legacy ([RFC 3921](https://xmpp.org/rfcs/rfc3921.html)): a request to unsubscribe has been sent. **/
	var unsubscribe;
}

/**
	Item of the roster (a contact).
**/
typedef RosterItem = {
	var jid:String;

	/** Name of the contact chosen by the user **/
	var ?name:String;

	/** State of the presence subscription, `remove` in a roster push for a removed item **/
	var ?subscription:Subscription;

	/** Pending subscription request **/
	var ?ask:AskType;

	/** The contact's subscription to the user's presence has been pre-approved **/
	var ?approved:Bool;

	var groups:Array<String>;
}

/**
	Roster (contact list), as returned by `loadRoster`.
**/
typedef RosterData = {
	/** Roster version, `null` if the server does not support roster versioning **/
	var ?ver:String;

	var items:Array<RosterItem>;
}

/**
	Manage the roster and presence subscriptions.

	The roster is stored by the user's server so that it can be accessed from any device.
	Changes to the roster (by this or another client of the user, or by subscription state changes)
	are sent by the server as *roster pushes*, see `handleRequests`.

	Rules:
	- Request the roster after authentication (`loadRoster`), before sending initial presence.
	- When adding or updating items only `jid`, `name` and groups are set; group names must not be empty or duplicated.
	- Removing an item also cancels the subscriptions in both directions.
	- Presence subscriptions are managed with presence stanzas (`subscribePresence` …), the server updates the roster.

	[RFC 6121: Managing the Roster](https://xmpp.org/rfcs/rfc6121.html#roster)
	[RFC 6121: Managing Presence Subscriptions](https://xmpp.org/rfcs/rfc6121.html#sub)
**/
class Roster {
	public static inline var XMLNS = "jabber:iq:roster";

	/** Stream feature announcing roster versioning support **/
	public static inline var XMLNS_VER = "urn:xmpp:features:rosterver";

	/**
		Returns `true` if the server supports roster versioning.
	**/
	@:noUsing
	public static function isVersioningOffered(features:Null<XML>):Bool
		return features != null && features.elements.first(e -> e.name == "ver" && e.is(XMLNS_VER)) != null;

	/**
		Retrieve the roster, use `parseRoster` to read the result.

		With roster versioning, pass the version of the cached roster as `ver` (an empty string if there is no cache):
		an empty result (`null` payload) means the cached roster is up to date, the changes are then sent as roster pushes.
	**/
	public static function loadRoster(stream:Stream, ?ver:String, handler:Response<XML>->Void):IQ {
		final query = Payload.create(XMLNS);
		if (ver != null)
			query.set("ver", ver);
		return stream.get(query, null, handler);
	}

	/**
		Add an item to the roster, or update an existing item (`name` and `groups` are replaced).
	**/
	public static function addRosterItem(stream:Stream, jid:String, ?name:String, ?groups:Array<String>, handler:Response<XML>->Void):IQ {
		final item = XML.create("item").set("jid", jid).set("name", name);
		if (groups != null) {
			final added = new Array<String>();
			for (g in groups) {
				if (g == null || g.length == 0 || added.contains(g))
					continue;
				added.push(g);
				item.append(XML.create("group", g));
			}
		}
		return stream.set(Payload.create(XMLNS).append(item), handler);
	}

	/**
		Remove an item from the roster; this also cancels the subscriptions in both directions.
	**/
	public static function removeRosterItem(stream:Stream, jid:String, handler:Response<XML>->Void):IQ
		return stream.set(Payload.create(XMLNS).append(XML.create("item").set("jid", jid).set("subscription", "remove")), handler);

	/**
		Request a subscription to the presence of `jid`, optionally with the user's `nickname`
		([XEP-0172](https://xmpp.org/extensions/xep-0172.html)).
	**/
	public static function subscribePresence(stream:Stream, jid:String, ?nickname:String):Presence {
		final p = createPresence(jid, subscribe);
		if (nickname != null)
			Nickname.nickname(p, nickname);
		stream.send(p);
		return p;
	}

	/**
		Cancel the subscription to the presence of `jid`.
	**/
	public static function unsubscribePresence(stream:Stream, jid:String):Presence
		return sendPresence(stream, jid, unsubscribe);

	/**
		Approve a subscription request of `jid`, or pre-approve a future request
		(if the server supports [pre-approval](https://xmpp.org/rfcs/rfc6121.html#sub-preapproval)).
	**/
	public static function approveSubscription(stream:Stream, jid:String):Presence
		return sendPresence(stream, jid, subscribed);

	/**
		Deny a subscription request of `jid`, or cancel a previously granted subscription.
	**/
	public static function cancelSubscription(stream:Stream, jid:String):Presence
		return sendPresence(stream, jid, unsubscribed);

	/**
		Answer roster pushes, calling `onPush` with the changed item (`subscription` is `remove` for a removed item)
		and the new roster version (`null` without roster versioning).

		Pushes not sent by the user's server (or account) are ignored.
	**/
	@:noUsing
	public static function handleRequests(stream:Stream, onPush:(item:RosterItem, ver:Null<String>) -> Void) {
		stream.features.set(XMLNS, (iq, respond) -> {
			if (iq.type != Set || !isValidPushSender(stream, iq.from)) {
				respond(Response.failure(cancel, service_unavailable));
				return;
			}
			final items = iq.payload.elements.named("item");
			if (items.length != 1 || !items[0].has("jid")) {
				respond(Response.failure(modify, bad_request));
				return;
			}
			respond(Response.success());
			onPush(parseItem(items[0]), iq.payload.get("ver"));
		});
	}

	/**
		Parses a roster `<query/>` (a `loadRoster` result or a roster push).
	**/
	@:noUsing
	public static function parseRoster(payload:XML):RosterData {
		final roster:RosterData = {items: [for (e in payload.elements) if (e.name == "item" && e.has("jid")) parseItem(e)]};
		if (payload.has("ver"))
			roster.ver = payload.get("ver");
		return roster;
	}

	/**
		Parses a roster `<item/>`.
	**/
	@:noUsing
	public static function parseItem(xml:XML):RosterItem {
		final item:RosterItem = {jid: xml.get("jid"), groups: []};
		if (xml.has("name"))
			item.name = xml.get("name");
		if (xml.has("subscription"))
			item.subscription = Subscription.fromString(xml.get("subscription"));
		if (xml.has("ask"))
			item.ask = xml.get("ask");
		final approved = xml.get("approved");
		if (approved == "true" || approved == "1")
			item.approved = true;
		for (e in xml.elements.named("group")) {
			final g:Null<String> = e.text;
			if (g != null && g.length > 0 && !item.groups.contains(g))
				item.groups.push(g);
		}
		return item;
	}

	/**
		Roster pushes are valid if they have no `from` or are sent from the user's bare jid.
	**/
	static function isValidPushSender(stream:Stream, from:Null<String>):Bool {
		if (from == null)
			return true;
		if (stream.jid == null)
			return false;
		return Jid.normalize(Jid.parseBare(from)) == Jid.normalize(Jid.parseBare(stream.jid));
	}

	static function sendPresence(stream:Stream, jid:String, type:PresenceType):Presence {
		final p = createPresence(jid, type);
		stream.send(p);
		return p;
	}

	static function createPresence(jid:String, type:PresenceType):Presence {
		final p = new Presence(null, null, null, type);
		p.to = jid;
		p.id = xmpp.Stream.makeRandomId();
		return p;
	}
}
