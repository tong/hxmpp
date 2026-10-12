package xmpp;

import xmpp.IQ;

/**
	Purpose of an upload, allowing the service to apply different retention periods.
**/
enum UploadPurpose {
	/** File attached to a message (default) **/
	MessageAttachment;

	/** File for a profile, e.g. an avatar; kept longer **/
	Profile;

	/** File that MUST NOT be available after `expireBefore` **/
	Ephemeral(expireBefore:Date);
}

typedef HttpUploadHeader = {
	var name:String;
	var value:String;
}

typedef HttpUploadSlot = {
	/** Url to upload the file to with HTTP `PUT` **/
	var put:String;

	/** Url the file can be downloaded from with HTTP `GET` **/
	var get:String;

	/** Headers to include in the `PUT` request (only `Authorization`, `Cookie` and `Expires`) **/
	var headers:Array<HttpUploadHeader>;
}

/**
	Allows to request permissions from another entity to upload a file to a specific path on an HTTP server and at the same time receive a URL from which that file can later be downloaded again.

	Flow: request a slot from the upload service (`requestHttpUploadSlot`), read it with `parseSlot`,
	upload the file with HTTP `PUT` (not part of this library) including the slot `headers`, a `Content-Length`
	matching the requested size and the requested `Content-Type`, then share the `get` url.

	[XEP-0363: HTTP File Upload](https://xmpp.org/extensions/xep-0363.html)
**/
@xep(363)
class HttpFileUpload {
	public static inline var XMLNS = "urn:xmpp:http:upload:0";
	public static inline var XMLNS_PURPOSE = "urn:xmpp:http:upload:purpose:0";

	/** Headers a slot may provide for the upload **/
	static final ALLOWED_HEADERS = ["authorization", "cookie", "expires"];

	/**
		Request an upload slot from the upload service `jid` for a file of `size` bytes.
	**/
	public static function requestHttpUploadSlot(stream:Stream, jid:String, filename:String, size:Float, ?contentType:haxe.io.Mime, ?purpose:UploadPurpose,
			handler:Response<XML>->Void):IQ {
		final xml = Payload.create(XMLNS, "request").set("filename", filename).set("size", haxe.Int64.toStr(haxe.Int64.fromFloat(size)));
		if (contentType != null)
			xml.set("content-type", contentType);
		if (purpose != null)
			xml.append(switch purpose {
				case MessageAttachment: XML.create("message").set("xmlns", XMLNS_PURPOSE);
				case Profile: XML.create("profile").set("xmlns", XMLNS_PURPOSE);
				case Ephemeral(expireBefore):
					XML.create("ephemeral").set("xmlns", XMLNS_PURPOSE).set("expire-before", DelayedDelivery.formatStamp(expireBefore));
			});
		return stream.get(xml, jid, handler);
	}

	/**
		Parses a `<slot/>` element, returns `null` if the `put` or `get` url is missing.

		Only the allowed headers (`Authorization`, `Cookie`, `Expires`) are returned, with newlines removed.
	**/
	@:noUsing
	public static function parseSlot(xml:XML):Null<HttpUploadSlot> {
		final put = xml.elements.findElement("put");
		final get = xml.elements.findElement("get");
		if (put == null || get == null || !put.has("url") || !get.has("url"))
			return null;
		final headers = new Array<HttpUploadHeader>();
		for (e in put.elements) {
			if (e.name != "header" || !e.has("name"))
				continue;
			final name = removeNewlines(e.get("name"));
			if (ALLOWED_HEADERS.contains(name.toLowerCase()))
				headers.push({name: name, value: removeNewlines(e.text ?? "")});
		}
		return {put: put.get("url"), get: get.get("url"), headers: headers};
	}

	/**
		Returns the maximum file size in bytes if the slot request failed because the file is too large, or `null`.
	**/
	@:noUsing
	public static function getMaxFileSize(error:Null<xmpp.Stanza.Error>):Null<Float> {
		final e = appError(error, "file-too-large");
		if (e == null)
			return null;
		final max = e.elements.findElement("max-file-size");
		return (max == null || max.text == null) ? null : Std.parseFloat(max.text);
	}

	/**
		Returns the time a new slot may be requested if the request failed temporarily (e.g. quota exceeded), or `null`.
	**/
	@:noUsing
	public static function getRetry(error:Null<xmpp.Stanza.Error>):Null<Date> {
		final e = appError(error, "retry");
		return (e == null) ? null : DelayedDelivery.parseStamp(e.get("stamp"));
	}

	/**
		Respond to a slot request with the upload (`PUT`) and download (`GET`) urls.

		Allowed `headers` for the upload are `Authorization`, `Cookie` and `Expires`.
	**/
	public static function sendHttpUploadSlot(stream:Stream, req:IQ, urlPut:String, urlGet:String, ?headers:Map<String, String>) {
		final put = XML.create("put").set("url", urlPut);
		if (headers != null)
			for (name => value in headers)
				put.append(XML.create("header", value).set("name", name));
		stream.send(req.createResult(XML.create("slot")
			.set("xmlns", XMLNS)
			.append(put)
			.append(XML.create("get").set("url", urlGet))));
	}

	static function appError(error:Null<xmpp.Stanza.Error>, name:String):Null<XML> {
		if (error == null || error.app == null || error.app.xmlns != XMLNS || error.app.condition != name)
			return null;
		return error.app.element;
	}

	static function removeNewlines(s:String):String
		return ~/[\r\n]/g.replace(s, "");
}
