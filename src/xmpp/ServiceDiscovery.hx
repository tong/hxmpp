package xmpp;

import xmpp.IQ;

typedef Identity = {
	category:String,
	type:String,
	name:String,
	?lang:String
}

/**
	Discover information about other XMPP entities.

	[XEP-0030: Service Discovery](https://xmpp.org/extensions/xep-0030.html)
**/
@xep(30)
class ServiceDiscovery {
	public static inline var XMLNS_INFO = "http://jabber.org/protocol/disco#info";
	public static inline var XMLNS_ITEMS = "http://jabber.org/protocol/disco#items";

	/**
		Discover the identity and capabilities of an entity, including the protocols and features it supports.
	**/
	public static inline function discoInfo(stream:Stream, ?jid:String, ?node:String, handler:Response<XML>->Void):IQ
		return disco(stream, XMLNS_INFO, jid, node, handler);

	/**
		Discover the items associated with an entity, such as the list of rooms hosted at a multi-user chat service.
	**/
	public static inline function discoItems(stream:Stream, ?jid:String, ?node:String, handler:Response<Payload>->Void):IQ
		return disco(stream, XMLNS_ITEMS, jid, node, handler);

	static function disco(stream:Stream, xmlns:String, ?jid:String, ?node:String, handler:Response<Payload>->Void):IQ {
		final xml = Payload.create(xmlns);
		if (node != null)
			xml.set("node", node);
		return stream.get(xml, jid ?? stream.domain, handler);
	}
}
