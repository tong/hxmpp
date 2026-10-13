package xmpp;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import xmpp.IQ;
import xmpp.ServiceDiscovery;

/**
	Capabilities advertised in a presence `<c/>` element.
**/
typedef Capabilities = {
	/** Identifies the software, e.g. its website **/
	var node:String;

	/** Verification string: the hash of the disco#info result **/
	var ver:String;

	/** Hash algorithm, `sha-1` if the legacy format (no `hash` attribute) is used **/
	var hash:String;
}

/**
	Advertise the features of an entity in its presence, so other entities don't need to query them (disco#info)
	for every presence received: the verification string is a hash of the identities, features and extended
	information forms, and stays the same until they change.

		final caps = EntityCapabilities.handleRequests(stream, {category: "client", type: "console", name: "norc"}, "https://github.com/tong/norc");
		final presence = new Presence();
		presence.properties.push(caps());
		stream.send(presence);

	Received capabilities (`parse`) are resolved with a disco#info request to `node#ver` once, the result is
	checked (`verify`) and can be cached by the verification string.

	[XEP-0115: Entity Capabilities](https://xmpp.org/extensions/xep-0115.html)
**/
@xep(115)
class EntityCapabilities {
	public static inline var XMLNS = "http://jabber.org/protocol/caps";

	/**
		Answers disco#info requests (see `ServiceDiscovery.handleRequests`) including requests for the node `node#ver`,
		and returns a function creating the `<c/>` element to add to presences.

		The features are determined when the function is called and on each request: register request handlers
		(e.g. `Ping.handleRequests`) before sending a presence with capabilities, and send a new presence if they change.
	**/
	@:noUsing
	public static function handleRequests(stream:Stream, identity:Identity, node:String, ?features:Array<String>):() -> XML {
		function info():DiscoInfo
			return {identities: [identity], features: ServiceDiscovery.getFeatures(stream, features), forms: []};
		final previous = stream.features.get(ServiceDiscovery.XMLNS_INFO);
		stream.features.set(ServiceDiscovery.XMLNS_INFO, (iq, respond) -> {
			final requested = iq.payload.get("node");
			if (requested != null && requested == '$node#${verificationString(info())}') {
				final i = info();
				respond((iq.type == Get) ? Response.success(ServiceDiscovery.createInfo(identity, i.features)
					.set("node", requested)) : Response.failure(cancel, bad_request));
			} else if (previous != null)
				previous(iq, respond);
			else
				respond(Response.failure(cancel, item_not_found));
		});
		// answers all other disco#info requests, passes node requests to the handler above
		ServiceDiscovery.handleRequests(stream, identity, features);
		return () -> createElement(node, verificationString(info()));
	}

	/**
		Creates a `<c/>` element.
	**/
	@:noUsing
	public static function createElement(node:String, ver:String, hash = "sha-1"):XML
		return XML.create("c").set("xmlns", XMLNS).set("hash", hash).set("node", node).set("ver", ver);

	/**
		Returns the capabilities of a presence, or `null` if it has none.
	**/
	@:noUsing
	public static function parse(presence:Presence):Null<Capabilities> {
		for (e in presence.properties)
			if (e.name == "c" && e.is(XMLNS) && e.has("node") && e.has("ver"))
				return {node: e.get("node"), ver: e.get("ver"), hash: e.get("hash") ?? "sha-1"};
		return null;
	}

	/**
		Returns `true` if `ver` is the verification string of `info` (a disco#info result of `node#ver`).
		Only `sha-1` is supported.
	**/
	@:noUsing
	public static function verify(info:DiscoInfo, ver:String, hash = "sha-1"):Bool
		return hash == "sha-1" && verificationString(info) == ver;

	/**
		Returns the verification string (`sha-1`, base64 encoded) of a disco#info result.
	**/
	@:noUsing
	public static function verificationString(info:DiscoInfo):String {
		final s = new StringBuf();
		final identities = [
			for (i in info.identities)
				'${i.category}/${i.type}/${i.lang ?? ""}/${i.name ?? ""}'
		];
		identities.sort(compare);
		for (i in identities)
			s.add('$i<');
		final features = info.features.copy();
		features.sort(compare);
		for (f in features)
			s.add('$f<');
		final forms = [for (form in info.forms) if (form.formType != null) form];
		forms.sort((a, b) -> compare(a.formType, b.formType));
		for (form in forms) {
			s.add('${form.formType}<');
			final fields = [
				for (f in form.fields) if (f.variable != null && f.variable != DataForm.FORM_TYPE) f
			];
			fields.sort((a, b) -> compare(a.variable, b.variable));
			for (f in fields) {
				s.add('${f.variable}<');
				final values = (f.values ?? []).copy();
				values.sort(compare);
				for (v in values)
					s.add('$v<');
			}
		}
		return Base64.encode(haxe.crypto.Sha1.make(Bytes.ofString(s.toString())));
	}

	static function compare(a:String, b:String):Int
		return a < b ? -1 : a > b ? 1 : 0;
}
