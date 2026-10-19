package xmpp;

import haxe.crypto.Base64;
import haxe.io.Bytes;
import xmpp.IQ;

/**
	The public keys of an OMEMO device, as published (the keys encoded as libsignal does: type and key).
**/
typedef OmemoBundle = {
	var identityKey:Bytes;
	var signedPreKeyId:Int;
	var signedPreKey:Bytes;
	var signedPreKeySignature:Bytes;
	var preKeys:Array<{id:Int, key:Bytes}>;
}

/**
	An OMEMO encrypted message: the device of the sender, the key of the payload for each recipient device
	(`preKey`: a message starting a session), the IV and the payload (`null`: an empty message, e.g. to complete
	a session).
**/
typedef OmemoEncrypted = {
	var sid:Int;
	var keys:Array<{rid:Int, data:Bytes, preKey:Bool}>;
	var iv:Bytes;
	var ?payload:Bytes;
}

/**
	OMEMO end-to-end encryption, version 0.3 (`eu.siacs.conversations.axolotl`), the one Conversations, Dino, Gajim,
	Monal and Profanity use: the XML of devices, bundles and messages. The cryptography (X3DH, Double Ratchet) is not
	part of this, see e.g. hxomemo.

	- Each client of an account is a device with an id; the account's device list (PEP node `NODE_DEVICELIST`, item
	  `current`) lists them. Contacts subscribe to it with `XMLNS_DEVICELIST_NOTIFY`. A client adds its own id if it
	  is missing (another client may have published a list without it).
	- Each device publishes its bundle (`NODE_BUNDLES` + its id): identity key, signed prekey and prekeys.
	- A message is encrypted for all devices of the contact and the own other devices; `<encrypted>` holds the key
	  for each (`rid`), the sender's device (`sid`), the IV, the payload. Only the body is encrypted.
	- Messages get the hint to store them (`urn:xmpp:hints`), the name of the encryption (XEP-0380) and a body for
	  clients without OMEMO (`addTo`).

	Both nodes are published with the access model `open` (`OPTIONS`): if the node exists with another one, publishing
	fails with `precondition-not-met`; configure it then (`PubSub.configNode`) and publish again.

	@see [XEP-0384: OMEMO Encryption (0.3)](https://xmpp.org/extensions/attic/xep-0384-0.3.0.html)
	@see [XEP-0380: Explicit Message Encryption](https://xmpp.org/extensions/xep-0380.html)
**/
@xep(384)
class Omemo {
	public static inline var XMLNS = "eu.siacs.conversations.axolotl";
	public static inline var NODE_DEVICELIST = XMLNS + ".devicelist";

	/** The node of a bundle: with the device id appended **/
	public static inline var NODE_BUNDLES = XMLNS + ".bundles:";

	/** Feature to advertise (entity capabilities) to get the device lists of contacts **/
	public static inline var XMLNS_DEVICELIST_NOTIFY = NODE_DEVICELIST + "+notify";

	public static inline var XMLNS_EME = "urn:xmpp:eme:0";
	static inline var XMLNS_HINTS = "urn:xmpp:hints";

	/** The body of encrypted messages for clients without OMEMO **/
	public static inline var FALLBACK_BODY = "I sent you an OMEMO encrypted message but your client doesn't seem to support that.";

	/** Publish options of both nodes: readable by everybody **/
	public static final OPTIONS = ["pubsub#access_model" => "open"];

	/** Publishes the own device list (item `current`) **/
	public static function publishDeviceList(stream:Stream, devices:Array<Int>, handler:Response<XML>->Void):IQ {
		final list = XML.create("list").set("xmlns", XMLNS);
		for (d in devices)
			list.append(XML.create("device").set("id", Std.string(d)));
		return PubSub.publish(stream, null, NODE_DEVICELIST, XML.create("item").set("id", "current").append(list), OPTIONS, handler);
	}

	/** Loads the device list of `jid` (a bare jid, `null`: the own), see `parseDeviceList` **/
	public static inline function loadDeviceList(stream:Stream, ?jid:String, handler:Response<XML>->Void):IQ
		return PubSub.loadItems(stream, jid, NODE_DEVICELIST, handler);

	/**
		The device ids of a `<list/>`, of a notification's `<items/>`, or of a response of `loadDeviceList` (its last
		item); empty if there are none. Invalid ids are left out.
	**/
	public static function parseDeviceList(xml:Null<XML>):Array<Int> {
		final list = find(xml, "list");
		if (list == null)
			return [];
		final devices = new Array<Int>();
		for (e in list.elements.named("device")) {
			final id = parseId(e.get("id"));
			if (id != null && !devices.contains(id))
				devices.push(id);
		}
		return devices;
	}

	/** Publishes the bundle of the own device `device` **/
	public static function publishBundle(stream:Stream, device:Int, bundle:OmemoBundle, handler:Response<XML>->Void):IQ {
		final e = XML.create("bundle").set("xmlns", XMLNS);
		e.append(XML.create("signedPreKeyPublic", Base64.encode(bundle.signedPreKey)).set("signedPreKeyId", Std.string(bundle.signedPreKeyId)));
		e.append(XML.create("signedPreKeySignature", Base64.encode(bundle.signedPreKeySignature)));
		e.append(XML.create("identityKey", Base64.encode(bundle.identityKey)));
		final prekeys = XML.create("prekeys");
		for (k in bundle.preKeys)
			prekeys.append(XML.create("preKeyPublic", Base64.encode(k.key)).set("preKeyId", Std.string(k.id)));
		e.append(prekeys);
		return PubSub.publish(stream, null, NODE_BUNDLES + device, XML.create("item").set("id", "current").append(e), OPTIONS, handler);
	}

	/** Loads the bundle of the device `device` of `jid` (`null`: the own account), see `parseBundle` **/
	public static inline function loadBundle(stream:Stream, ?jid:String, device:Int, handler:Response<XML>->Void):IQ
		return PubSub.loadItems(stream, jid, NODE_BUNDLES + device, 1, handler);

	/**
		The bundle in a `<bundle/>`, or in a response of `loadBundle`; `null` if it is missing or incomplete. Prekeys
		without id or key are left out.
	**/
	public static function parseBundle(xml:Null<XML>):Null<OmemoBundle> {
		final b = find(xml, "bundle");
		if (b == null)
			return null;
		final spk = b.elements.named("signedPreKeyPublic")[0];
		final spkId = parseId(spk?.get("signedPreKeyId"));
		final spkKey = bytes(spk), signature = bytes(b.elements.named("signedPreKeySignature")[0]), identity = bytes(b.elements.named("identityKey")[0]);
		if (spkId == null || spkKey == null || signature == null || identity == null)
			return null;
		final preKeys = [];
		for (prekeys in b.elements.named("prekeys"))
			for (e in prekeys.elements.named("preKeyPublic")) {
				final id = parseId(e.get("preKeyId")), key = bytes(e);
				if (id != null && key != null)
					preKeys.push({id: id, key: key});
			}
		return {
			identityKey: identity,
			signedPreKeyId: spkId,
			signedPreKey: spkKey,
			signedPreKeySignature: signature,
			preKeys: preKeys
		};
	}

	/** The `<encrypted/>` element of a message **/
	public static function createEncrypted(e:OmemoEncrypted):XML {
		final header = XML.create("header").set("sid", Std.string(e.sid));
		for (k in e.keys) {
			final key = XML.create("key", Base64.encode(k.data)).set("rid", Std.string(k.rid));
			if (k.preKey)
				key.set("prekey", "true");
			header.append(key);
		}
		header.append(XML.create("iv", Base64.encode(e.iv)));
		final xml = XML.create("encrypted").set("xmlns", XMLNS).append(header);
		if (e.payload != null)
			xml.append(XML.create("payload", Base64.encode(e.payload)));
		return xml;
	}

	/**
		Adds the encrypted message to `message`: the `<encrypted/>`, the hint to store it, the encryption's name, and
		the body for clients without OMEMO (`body`: else `FALLBACK_BODY`; not for an empty message)
	**/
	public static function addTo(message:Message, e:OmemoEncrypted, ?body:String):Message {
		message.properties.push(createEncrypted(e));
		message.properties.push(XML.create("store").set("xmlns", XMLNS_HINTS));
		message.properties.push(XML.create("encryption").set("xmlns", XMLNS_EME).set("namespace", XMLNS).set("name", "OMEMO"));
		message.body = (e.payload == null) ? null : body ?? FALLBACK_BODY;
		return message;
	}

	/** The encrypted message in a message (its `<encrypted/>`), `null` if there is none or it is invalid **/
	public static function getEncrypted(message:Message):Null<OmemoEncrypted> {
		for (e in message.properties)
			if (e.name == "encrypted" && e.is(XMLNS))
				return parseEncrypted(e);
		return null;
	}

	public static function parseEncrypted(xml:XML):Null<OmemoEncrypted> {
		final header = xml.elements.named("header")[0];
		final sid = parseId(header?.get("sid"));
		final iv = bytes(header?.elements.named("iv")[0]);
		if (sid == null || iv == null)
			return null;
		final keys = [];
		for (k in header.elements.named("key")) {
			final rid = parseId(k.get("rid")), data = bytes(k);
			if (rid != null && data != null)
				keys.push({rid: rid, data: data, preKey: k.get("prekey") == "true" || k.get("prekey") == "1"});
		}
		final e:OmemoEncrypted = {sid: sid, keys: keys, iv: iv};
		final payload = xml.elements.named("payload")[0];
		if (payload != null) {
			final p = bytes(payload);
			if (p == null)
				return null;
			e.payload = p;
		}
		return e;
	}

	/** An id (device, prekey): a number from 0 to 2^31-1 **/
	static function parseId(s:Null<String>):Null<Int> {
		if (s == null || !~/^[0-9]{1,10}$/.match(s))
			return null;
		final f = Std.parseFloat(s);
		return f > 0x7fffffff ? null : Std.int(f);
	}

	/** The base64 content of an element (whitespace removed), `null` if empty or invalid **/
	static function bytes(e:Null<XML>):Null<Bytes> {
		final text:Null<String> = e?.text;
		if (text == null)
			return null;
		final s = ~/\s+/g.replace(text, "");
		return (s.length == 0) ? null : try Base64.decode(s) catch (_) null;
	}

	/** `xml` if it is the element, else the element in its (last) item, also of `<pubsub><items>` **/
	static function find(xml:Null<XML>, name:String):Null<XML> {
		if (xml == null)
			return null;
		if (xml.name == name && xml.is(XMLNS))
			return xml;
		final items = (xml.name == "items") ? xml : xml.elements.named("items")[0];
		final list = (xml.name == "item") ? [xml] : items?.elements.named("item") ?? [];
		final item = (list.length == 0) ? null : list[list.length - 1];
		return item?.elements.first(e -> e.name == name && e.is(XMLNS));
	}
}
