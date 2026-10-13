package xmpp;

import xmpp.IQ;

typedef TSoftwareVersion = {
	?name:String,
	?version:String,
	?os:String,
}

/**
	[XEP-0092: Software Version](https://xmpp.org/extensions/xep-0092.html)
**/
@xep(92)
class SoftwareVersion {
	public static inline var XMLNS = "jabber:iq:version";

	/**
		Request software version information from entity.
	**/
	public static inline function getSoftwareVersion(stream:Stream, ?jid:String, handler:Response<XML>->Void):IQ
		return stream.get(XMLNS, jid ?? stream.domain, handler);

	/**
		Parses the result of `getSoftwareVersion`; fields not given are `null`.
	**/
	@:noUsing
	public static function parse(payload:Null<XML>):TSoftwareVersion {
		final info:TSoftwareVersion = {};
		if (payload == null)
			return info;
		for (e in payload.elements) {
			final text:Null<String> = e.text;
			if (text == null || StringTools.trim(text).length == 0)
				continue;
			switch e.name {
				case "name":
					info.name = StringTools.trim(text);
				case "version":
					info.version = StringTools.trim(text);
				case "os":
					info.os = StringTools.trim(text);
				case _:
			}
		}
		return info;
	}

	/**
		Answer software version requests with `info` (fields set to `null` are left out, e.g. `os` for privacy).
	**/
	@:noUsing
	public static function handleRequests(stream:Stream, info:TSoftwareVersion) {
		stream.features.set(XMLNS, (iq, respond) -> {
			if (iq.type != Get) {
				respond(Response.failure(cancel, bad_request));
				return;
			}
			final xml = Payload.create(XMLNS);
			if (info.name != null)
				xml.append(XML.create("name", info.name));
			if (info.version != null)
				xml.append(XML.create("version", info.version));
			if (info.os != null)
				xml.append(XML.create("os", info.os));
			respond(Response.success(xml));
		});
	}

	/**
		Send software information
	**/
	public static inline function replySoftwareVersion(stream:Stream, iq:IQ, info:TSoftwareVersion):IQ {
		var xml = Payload.create(XMLNS)
			.append(XML.create("name", info.name))
			.append(XML.create("version", info.version))
			.append(XML.create("os", info.os));
		// var xml = XML.create('query').set('xmlns', XMLNS)
		//     .append(XML.create("name", info.name))
		//     .append(XML.create("version", info.version))
		//     .append(XML.create("os", info.os));
		var r = iq.createResult(xml);
		// var r = xmpp.IQ.createResult(iq, IQ.Payload.create(XMLNS,[
		//     XML.create("name", info.name),
		//     XML.create("version", info.version),
		//     XML.create("os", info.os)
		// ]));
		// if(info.name != null) r.payload.append(XML.create("name", info.name));
		// if(info.version != null) r.payload.append(XML.create("version", info.version));
		// if(info.os != null) r.payload.append(XML.create("os", info.os));
		stream.send(r);
		return r;
	}
}
