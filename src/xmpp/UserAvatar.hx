package xmpp;

import haxe.crypto.Base64;
import haxe.crypto.Sha1;
import haxe.io.Bytes;
import xmpp.IQ;

/** The description of an avatar image (an `<info/>` of the metadata) **/
typedef AvatarInfo = {
	/** The SHA-1 hash of the image (hex), also the id of its data item **/
	var id:String;

	/** Size of the image in bytes **/
	var bytes:Int;

	/** Content type, e.g. `image/png` **/
	var type:String;

	var ?width:Int;
	var ?height:Int;

	/** The image is not in the data node but at this URL **/
	var ?url:String;
}

/**
	Avatars published with PEP: the image in the data node (base64, item id the SHA-1 hash of the image), its
	description in the metadata node. Contacts get the metadata as notifications (`XMLNS_METADATA+notify`), then
	load the image if they don't have it yet (`loadData`).

	Rules:
	- Publish the data first, then the metadata (item id: the hash).
	- The metadata SHOULD describe an `image/png` version; others may be listed too.
	- Empty metadata means the user has no avatar anymore.
	- Check the hash of loaded data (`hash`) before using it.

	@see [XEP-0084: User Avatar](https://xmpp.org/extensions/xep-0084.html)
**/
@xep(84)
class UserAvatar {
	public static inline var XMLNS_DATA = "urn:xmpp:avatar:data";
	public static inline var XMLNS_METADATA = "urn:xmpp:avatar:metadata";

	/** The SHA-1 hash of `data` (hex, lowercase): the id of an avatar image **/
	public static function hash(data:Bytes):String
		return Sha1.make(data).toHex();

	/** Publishes the image `data` to the own data node (item id: its hash) **/
	public static function publishData(stream:Stream, data:Bytes, handler:Response<XML>->Void):IQ {
		final item = XML.create("item").set("id", hash(data)).append(XML.create("data", Base64.encode(data)).set("xmlns", XMLNS_DATA));
		return PubSub.publish(stream, null, XMLNS_DATA, item, handler);
	}

	/**
		Publishes the metadata of the own avatar: `infos` describe the image (and other versions of it), the first one
		gives the item id. Empty or `null`: the user has no avatar anymore.
	**/
	public static function publishMetadata(stream:Stream, ?infos:Array<AvatarInfo>, handler:Response<XML>->Void):IQ {
		final metadata = XML.create("metadata").set("xmlns", XMLNS_METADATA);
		for (i in infos ?? []) {
			final info = XML.create("info").set("id", i.id).set("bytes", Std.string(i.bytes)).set("type", i.type);
			if (i.width != null)
				info.set("width", Std.string(i.width));
			if (i.height != null)
				info.set("height", Std.string(i.height));
			if (i.url != null)
				info.set("url", i.url);
			metadata.append(info);
		}
		final item = XML.create("item").set("id", (infos != null && infos.length > 0) ? infos[0].id : "current").append(metadata);
		return PubSub.publish(stream, null, XMLNS_METADATA, item, handler);
	}

	/** Loads the current metadata of the avatar of `jid` (a bare jid, `null`: the own), see `parseMetadata` **/
	public static inline function loadMetadata(stream:Stream, ?jid:String, handler:Response<XML>->Void):IQ
		return PubSub.loadItems(stream, jid, XMLNS_METADATA, 1, handler);

	/** Loads the image with the hash `id` of the avatar of `jid` (`null`: the own), see `parseData` **/
	public static inline function loadData(stream:Stream, ?jid:String, id:String, handler:Response<XML>->Void):IQ
		return PubSub.loadItem(stream, jid, XMLNS_DATA, id, handler);

	/**
		The images described by a `<metadata/>` element, or by the first item of a response or notification
		containing it. Empty: no avatar (also without metadata). Infos without id, size or type are left out.
	**/
	public static function parseMetadata(xml:Null<XML>):Array<AvatarInfo> {
		final metadata = find(xml, "metadata", XMLNS_METADATA);
		if (metadata == null)
			return [];
		final infos = new Array<AvatarInfo>();
		for (e in metadata.elements.named("info")) {
			final bytes = Std.parseInt(e.get("bytes") ?? "");
			if (e.get("id") == null || bytes == null || e.get("type") == null)
				continue;
			final info:AvatarInfo = {id: e.get("id").toLowerCase(), bytes: bytes, type: e.get("type")};
			final width = Std.parseInt(e.get("width") ?? ""), height = Std.parseInt(e.get("height") ?? "");
			if (width != null)
				info.width = width;
			if (height != null)
				info.height = height;
			if (e.get("url") != null)
				info.url = e.get("url");
			infos.push(info);
		}
		return infos;
	}

	/** The image in a `<data/>` element, or in a response of `loadData`; `null` if there is none or it is invalid **/
	public static function parseData(xml:Null<XML>):Null<Bytes> {
		final data = find(xml, "data", XMLNS_DATA);
		if (data == null)
			return null;
		final text:Null<String> = data.text;
		return (text == null) ? null : try Base64.decode(~/\s+/g.replace(text, "")) catch (_) null;
	}

	/** `xml` if it is the element, else the element in its first item (also of `<pubsub><items>`) **/
	static function find(xml:Null<XML>, name:String, ns:String):Null<XML> {
		if (xml == null)
			return null;
		if (xml.name == name && xml.is(ns))
			return xml;
		final items = (xml.name == "items") ? xml : xml.elements.named("items")[0];
		final item = (xml.name == "item") ? xml : items?.elements.named("item")[0];
		return item?.elements.first(e -> e.name == name && e.is(ns));
	}
}
