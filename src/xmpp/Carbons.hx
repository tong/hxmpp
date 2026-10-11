package xmpp;

import xmpp.IQ;

/**
	Carbon copy outbound messages to all interested resources.

	[XEP-0280: Message Carbons](https://xmpp.org/extensions/xep-0280.html)
**/
@xep(280)
class Carbons {
	public static inline var XMLNS = "urn:xmpp:carbons:2";

	public static inline function enableMessageCarbons(stream:Stream, handler:Response<XML>->Void):IQ
		return stream.set(Payload.create(XMLNS, "enable"), handler);

	// public static inline function enableMessageCarbons(stream: Stream, handler: xmpp.Stanza.Error->Void):IQ
	//     return stream.set(Payload.create(XMLNS, "enable"), handler);

	public static inline function disableMessageCarbons(stream:Stream, handler:Response<XML>->Void):IQ
		return stream.set(Payload.create(XMLNS, "disable"), handler);
}
