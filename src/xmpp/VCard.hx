package xmpp;

import xmpp.IQ;

/**
	vcard-temp

	[XEP-0054: vcard-temp](https://xmpp.org/extensions/xep-0054.html)
**/
@xep(54)
class VCard {
	public static inline var XMLNS = "vcard-temp";

	public static inline function getVCard(stream:Stream, ?jid:String, handler:Response<XML>->Void):IQ
		return stream.get(Payload.create(XMLNS, "vCard"), jid, handler);

	public static inline function setVCard(stream:Stream, vcard:XML, handler:Response<XML>->Void):IQ
		return stream.set(Payload.create(XMLNS, "vCard").append(vcard), handler);
}
