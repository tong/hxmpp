package xmpp;

import xmpp.IQ;
import xmpp.Response.EResponse;

typedef OobData = {
	/** Url of the resource **/
	var url:String;

	/** Description of the resource **/
	var ?desc:String;
}

/**
	Answer of the recipient of an out-of-band file transfer request.
**/
enum OobResult {
	/** The file was retrieved completely **/
	Fetched;

	/** The file could not be retrieved **/
	Failed;

	/** The request is rejected **/
	Rejected;
}

/**
	Communicate URIs of out-of-band data:
	- `jabber:iq:oob`: request a recipient to retrieve a file (`oob`, `handleRequests`)
	- `jabber:x:oob`: attach a url to a message or presence (`setOob`, `getOob`)

	An entity supporting it MUST advertise the `XMLNS` and/or `XMLNS_X` feature in its service discovery responses.

	[XEP-0066: Out of Band Data](https://xmpp.org/extensions/xep-0066.html)
**/
@xep(66)
class Oob {
	public static inline var XMLNS = "jabber:iq:oob";
	public static inline var XMLNS_X = "jabber:x:oob";

	/**
		Request the entity `jid` to retrieve the file at `url`.

		The recipient answers with a result once it has retrieved the complete file,
		`item-not-found` if it failed, or `not-acceptable` if it rejected the request.
	**/
	public static function oob(stream:Stream, jid:String, url:String, ?desc:String, ?sid:String, handler:Response<XML>->Void):IQ {
		final x = Payload.create(XMLNS).append(XML.create("url", url));
		if (desc != null)
			x.append(XML.create("desc", desc));
		if (sid != null)
			x.set("sid", sid);
		return stream.set(x, jid, handler);
	}

	/**
		Handle out-of-band file transfer requests.

		`handler` is called with the url and description, and MUST call `respond` once
		the file was retrieved completely (`Fetched`), retrieving failed (`Failed`), or with `Rejected`.
	**/
	public static function handleRequests(stream:Stream, handler:(url:String, desc:Null<String>, from:Null<String>, respond:OobResult->Void) -> Void) {
		stream.features.set(XMLNS, (iq, respond) -> {
			final data = (iq.type == Set) ? parse(iq.payload) : null;
			if (data == null) {
				respond(EResponse.Error(new xmpp.Stanza.Error(modify, bad_request)));
				return;
			}
			handler(data.url, data.desc, iq.from, result -> respond(switch result {
				case Fetched: EResponse.Result(null);
				case Failed: EResponse.Error(new xmpp.Stanza.Error(cancel, item_not_found));
				case Rejected: EResponse.Error(new xmpp.Stanza.Error(modify, not_acceptable));
			}));
		});
	}

	/**
		Returns the out-of-band url attached to the given message or presence, or `null`.
	**/
	public static function getOob(stanza:Stanza):Null<OobData> {
		for (e in stanza.properties)
			if (e.name == "x" && e.is(XMLNS_X))
				return parse(e);
		return null;
	}

	/**
		Attaches an out-of-band url to the given message.
	**/
	public static function setOob(message:Message, url:String, ?desc:String):Message {
		final x = Payload.create(XMLNS_X, "x").append(XML.create("url", url));
		if (desc != null)
			x.append(XML.create("desc", desc));
		message.properties.push(x);
		return message;
	}

	/**
		Parses a `jabber:iq:oob` `<query/>` or `jabber:x:oob` `<x/>` element, returns `null` without url.
	**/
	@:noUsing
	public static function parse(xml:XML):Null<OobData> {
		final url = xml.elements.findElement("url");
		if (url == null || url.text == null)
			return null;
		final desc = xml.elements.findElement("desc");
		final data:OobData = {url: StringTools.trim(url.text)};
		if (desc != null && desc.text != null)
			data.desc = desc.text;
		return data;
	}
}
