package xmpp;

import xmpp.IQ;
import xmpp.Response.EResponse;

/**
	Application-level pings, e.g. to check that the connection or another entity is alive.

	An entity answering pings MUST advertise the `XMLNS` feature in its service discovery responses.

	[XEP-0199: XMPP Ping](https://xmpp.org/extensions/xep-0199.html)
**/
@xep(199)
class Ping {
	public static inline var XMLNS = "urn:xmpp:ping";

	/**
		Ping the entity `jid`, or the server if `null`.

		The response is an empty result, or `service-unavailable` if the entity does not support pings.
	**/
	public static inline function ping(stream:Stream, ?jid:String, ?handler:Response<XML>->Void):IQ
		return stream.get(Payload.create(XMLNS, "ping"), jid, handler);

	/**
		Answer pings of the server and other entities.
	**/
	@:noUsing
	public static function handleRequests(stream:Stream) {
		stream.features.set(XMLNS, (iq, respond) -> {
			respond((iq.type == Get) ? EResponse.Result(null) : EResponse.Error(new xmpp.Stanza.Error(cancel, bad_request)));
		});
	}
}
