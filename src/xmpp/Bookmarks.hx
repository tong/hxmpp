package xmpp;

import xmpp.IQ;
import xmpp.PubSub;

/**
	A bookmark of a room.
**/
typedef Bookmark = {
	/** Bare jid of the room (the id of the bookmark) **/
	var jid:String;

	/** Friendly name of the room **/
	var ?name:String;

	/** Join the room when connecting **/
	var autojoin:Bool;

	/** The nick to use in the room **/
	var ?nick:String;

	var ?password:String;

	/** Other elements of the bookmark (e.g. of other clients), kept when it is changed **/
	var ?extensions:Array<XML>;
}

/**
	Bookmarks of rooms, stored on the server (in the personal eventing service of the account): shared by all clients
	of the account, which join the rooms marked `autojoin` when connecting.

	Each bookmark is an item of the node `XMLNS`, with the jid of the room as item id. Changes by other clients are
	notified to clients advertising `XMLNS_NOTIFY` (`PubSub.getEvent`, `Bookmarks.getChanges`).

		Bookmarks.load(stream, res -> switch res {
			case Result(payload): for (b in Bookmarks.parseItems(payload)) if (b.autojoin) join(b);
			case Error(e): // item-not-found: no bookmarks yet
		});
		Bookmarks.set(stream, {jid: "room@chat.example.org", autojoin: true, nick: "romeo"}, res -> {});

	[XEP-0402: PEP Native Bookmarks](https://xmpp.org/extensions/xep-0402.html)
**/
@xep(402)
class Bookmarks {
	public static inline var XMLNS = "urn:xmpp:bookmarks:1";

	/** Feature to advertise (entity capabilities) to get notified of changes **/
	public static inline var XMLNS_NOTIFY = XMLNS + "+notify";

	/** The configuration of the node: private, all bookmarks kept **/
	static final OPTIONS = [
		"pubsub#persist_items" => "true",
		"pubsub#max_items" => "max",
		"pubsub#send_last_published_item" => "never",
		"pubsub#access_model" => "whitelist"
	];

	/**
		Requests the bookmarks: the response payload contains the items (`parseItems`),
		an `item-not-found` error means there are none.
	**/
	public static function load(stream:Stream, handler:Response<XML>->Void):IQ
		return PubSub.loadItems(stream, null, XMLNS, handler);

	/**
		Adds a bookmark, or replaces the bookmark of the same room.
	**/
	public static function set(stream:Stream, bookmark:Bookmark, handler:Response<XML>->Void):IQ
		return PubSub.publish(stream, null, XMLNS, XML.create("item").set("id", bookmark.jid).append(create(bookmark)), OPTIONS, handler);

	/**
		Removes the bookmark of room `jid` (other clients are notified).
	**/
	public static function remove(stream:Stream, jid:String, handler:Response<XML>->Void):IQ
		return stream.set(Payload.create(PubSub.XMLNS, "pubsub")
			.append(XML.create("retract").set("node", XMLNS).set("notify", "true").append(XML.create("item").set("id", jid))), handler);

	/**
		Creates the `<conference/>` payload of a bookmark.
	**/
	@:noUsing
	public static function create(bookmark:Bookmark):XML {
		final xml = XML.create("conference").set("xmlns", XMLNS).set("name", bookmark.name);
		if (bookmark.autojoin)
			xml.set("autojoin", "true");
		if (bookmark.nick != null)
			xml.append(XML.create("nick", bookmark.nick));
		if (bookmark.password != null)
			xml.append(XML.create("password", bookmark.password));
		if (bookmark.extensions != null && bookmark.extensions.length > 0) {
			final extensions = XML.create("extensions");
			for (e in bookmark.extensions)
				extensions.append(e);
			xml.append(extensions);
		}
		return xml;
	}

	/**
		Parses a bookmark: an `<item/>` (with the jid as id) containing a `<conference/>`; `null` if it is invalid.
	**/
	@:noUsing
	public static function parse(item:XML):Null<Bookmark> {
		final jid = item.get("id");
		final c = item.elements.first(e -> e.name == "conference" && e.is(XMLNS));
		if (jid == null || c == null || !Jid.isValid(jid))
			return null;
		final autojoin = c.get("autojoin");
		final b:Bookmark = {jid: jid, autojoin: autojoin == "true" || autojoin == "1"};
		if (c.has("name"))
			b.name = c.get("name");
		for (e in c.elements)
			switch e.name {
				case "nick": b.nick = e.text;
				case "password": b.password = e.text;
				case "extensions": b.extensions = e.elements;
				case _:
			}
		return b;
	}

	/**
		Parses the bookmarks of the response to `load`.
	**/
	@:noUsing
	public static function parseItems(payload:Null<XML>):Array<Bookmark> {
		final items = payload?.elements.first(e -> e.name == "items");
		return (items == null) ? [] : [for (i in items.elements.named("item")) parse(i)].filter(b -> b != null);
	}

	/**
		Returns the changed (`set`) and removed (`removed`, room jids) bookmarks notified by `message`, `null` if it is
		no notification of bookmarks.

		Notifications not from the own bare jid are ignored (`null`), since these may be forged.
	**/
	public static function getChanges(stream:Stream, message:Message):Null<{set:Array<Bookmark>, removed:Array<String>}> {
		if (stream.jid != null && message.from != null && Jid.normalize(Jid.parseBare(message.from)) != Jid.normalize(Jid.parseBare(stream.jid)))
			return null;
		return switch PubSub.getEvent(message) {
			case Items(node, items, retracted) if (node == XMLNS):
				{set: [for (i in items) parse(i)].filter(b -> b != null), removed: retracted};
			case Purge(node) | Delete(node) if (node == XMLNS):
				{set: [], removed: ["*"]};
			case _: null;
		}
	}
}
