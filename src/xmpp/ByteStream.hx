package xmpp;

import xmpp.IQ;

typedef StreamHost = {
	var host:String;
	var port:Int;
	var jid:String;
}

/**
	[XEP-0065: SOCKS5 Bytestreams](https://xmpp.org/extensions/xep-0065.html)
**/
@xep(65)
class ByteStream {
	public static inline var XMLNS = "http://jabber.org/protocol/bytestreams";

	public static inline function initByteStream(stream:Stream, jid:String, sid:String, hosts:Array<StreamHost>, handler:Response<XML>->Void) {
		var xml = Payload.create(XMLNS).set("sid", sid);
		for (h in hosts)
			xml.append(XML.create("streamhost")
				.set("host", h.host)
				.set("port", Std.string(h.port))
				.set("jid", h.jid));
		stream.set(xml, jid, handler);
	}
}
