package xmpp;

import xmpp.IQ;

/**
	Allows to request permissions from another entity to upload a file to a specific path on an HTTP server and at the same time receive a URL from which that file can later be downloaded again.

	[XEP-00363: HTTP File Upload](https://xmpp.org/extensions/xep-0363.html)
**/
@xep(363)
class HttpFileUpload {
	public static inline var XMLNS = "urn:xmpp:http:upload:0";

	/**
	**/
	public static function requestHttpUploadSlot(stream:Stream, jid:String, filename:String, size:Int, ?contentType:haxe.io.Mime,
			handler:Response<XML>->Void):IQ {
		final xml = Payload.create(XMLNS, "request").set("filename", filename).set("size", Std.string(size));
		if (contentType != null)
			xml.set("content-type", contentType);
		return stream.get(xml, jid, handler);
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
}
