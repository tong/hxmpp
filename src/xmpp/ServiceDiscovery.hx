package xmpp;

import xmpp.IQ;

/**
	Identity of an entity, e.g. `{category: "client", type: "pc"}`.

	@see [Service Discovery Identities](https://xmpp.org/registrar/disco-categories.html)
**/
typedef Identity = {
	var category:String;
	var type:String;
	var ?name:String;
	var ?lang:String;
}

/**
	Result of a disco#info request.
**/
typedef DiscoInfo = {
	var identities:Array<Identity>;

	/** Supported features (protocol namespaces) **/
	var features:Array<String>;

	/** Extended information ([XEP-0128](https://xmpp.org/extensions/xep-0128.html)) **/
	var forms:Array<DataForm>;
}

/**
	Item of a disco#items result.
**/
typedef DiscoItem = {
	var jid:String;
	var ?node:String;
	var ?name:String;
}

/**
	Discover information about other XMPP entities, and answer discovery requests.

	Note: `jid` and `node` are both optional strings; to query a node of the server pass `null` as `jid`.

	[XEP-0030: Service Discovery](https://xmpp.org/extensions/xep-0030.html)
**/
@xep(30)
class ServiceDiscovery {
	public static inline var XMLNS_INFO = "http://jabber.org/protocol/disco#info";
	public static inline var XMLNS_ITEMS = "http://jabber.org/protocol/disco#items";

	/**
		Discover the identity and capabilities of an entity (the server if `jid` is `null`),
		including the protocols and features it supports. Use `parseInfo` to read the result.
	**/
	public static inline function discoInfo(stream:Stream, ?jid:String, ?node:String, handler:Response<XML>->Void):IQ
		return disco(stream, XMLNS_INFO, jid, node, handler);

	/**
		Discover the items associated with an entity (the server if `jid` is `null`),
		such as the list of rooms hosted at a multi-user chat service. Use `parseItems` to read the result.
	**/
	public static inline function discoItems(stream:Stream, ?jid:String, ?node:String, handler:Response<XML>->Void):IQ
		return disco(stream, XMLNS_ITEMS, jid, node, handler);

	static function disco(stream:Stream, xmlns:String, ?jid:String, ?node:String, handler:Response<XML>->Void):IQ {
		final xml = Payload.create(xmlns);
		if (node != null)
			xml.set("node", node);
		return stream.get(xml, jid ?? stream.domain, handler);
	}

	/**
		Parses a disco#info result.
	**/
	@:noUsing
	public static function parseInfo(payload:XML):DiscoInfo {
		final info:DiscoInfo = {identities: [], features: [], forms: []};
		for (e in payload.elements) {
			switch e.name {
				case "identity" if (e.has("category") && e.has("type")):
					final identity:Identity = {category: e.get("category"), type: e.get("type")};
					if (e.has("name"))
						identity.name = e.get("name");
					if (e.has("xml:lang"))
						identity.lang = e.get("xml:lang");
					info.identities.push(identity);
				case "feature" if (e.has("var")):
					info.features.push(e.get("var"));
				case "x" if (e.is(DataForm.XMLNS)):
					info.forms.push(DataForm.fromXML(e));
				case _:
			}
		}
		return info;
	}

	/**
		Parses a disco#items result.
	**/
	@:noUsing
	public static function parseItems(payload:XML):Array<DiscoItem> {
		final items = new Array<DiscoItem>();
		for (e in payload.elements) {
			if (e.name != "item" || !e.has("jid"))
				continue;
			final item:DiscoItem = {jid: e.get("jid")};
			if (e.has("node"))
				item.node = e.get("node");
			if (e.has("name"))
				item.name = e.get("name");
			items.push(item);
		}
		return items;
	}

	/**
		Returns `true` if the disco#info result advertises `feature`.
	**/
	@:noUsing
	public static inline function hasFeature(info:DiscoInfo, feature:String):Bool
		return info.features.contains(feature);

	/**
		Answer service discovery requests of other entities.

		disco#info results contain `identity`, the disco#info feature, the namespaces of all request handlers
		registered in `stream.features` (e.g. by `Ping.handleRequests`) at the time of the request, and `features`
		for supported protocols without request handlers (e.g. `ChatState.XMLNS`).
		disco#items results are empty. Requests for nodes are answered with `item-not-found`.
	**/
	@:noUsing
	public static function handleRequests(stream:Stream, identity:Identity, ?features:Array<String>) {
		stream.features.set(XMLNS_INFO, (iq, respond) -> {
			if (iq.type != Get) {
				respond(Response.failure(cancel, bad_request));
				return;
			}
			if (iq.payload.has("node")) {
				respond(Response.failure(cancel, item_not_found));
				return;
			}
			respond(Response.success(createInfo(identity, getFeatures(stream, features))));
		});
		stream.features.set(XMLNS_ITEMS, (iq, respond) -> {
			if (iq.type != Get) {
				respond(Response.failure(cancel, bad_request));
				return;
			}
			respond(iq.payload.has("node") ? Response.failure(cancel, item_not_found) : Response.success(Payload.create(XMLNS_ITEMS)));
		});
	}

	/**
		Returns the sorted, unique features advertised for `stream`: disco#info, the namespaces of the
		registered request handlers, and `extra`.
	**/
	@:noUsing
	public static function getFeatures(stream:Stream, ?extra:Array<String>):Array<String> {
		final set = new Map<String, Bool>();
		set.set(XMLNS_INFO, true);
		for (ns in stream.features.keys())
			set.set(ns, true);
		if (extra != null)
			for (ns in extra)
				set.set(ns, true);
		final features = [for (ns in set.keys()) ns];
		features.sort((a, b) -> a < b ? -1 : a > b ? 1 : 0);
		return features;
	}

	/**
		Creates a disco#info `<query/>` with the given identity and features.
	**/
	@:noUsing
	public static function createInfo(identity:Identity, features:Array<String>):XML {
		final xml:XML = Payload.create(XMLNS_INFO);
		final e = XML.create("identity").set("category", identity.category).set("type", identity.type).set("name", identity.name);
		if (identity.lang != null)
			e.set("xml:lang", identity.lang);
		xml.append(e);
		for (f in features)
			xml.append(XML.create("feature").set("var", f));
		return xml;
	}
}
