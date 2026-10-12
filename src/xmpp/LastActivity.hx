package xmpp;

import xmpp.IQ;
import xmpp.Response.EResponse;

typedef TLastActivity = {
	/** Seconds since the last activity (see `LastActivity` for the meaning) **/
	var seconds:Int;

	/** Status message of the last unavailable presence, if any **/
	var ?status:String;
}

/**
	Communicate information about the last activity associated with an XMPP entity.

	The meaning of the result depends on the queried entity:
	- a **bare jid** (`user@domain`): seconds since the user logged out, `0` if online;
	  answered by the server only if subscribed to the user's presence (otherwise `forbidden`)
	- a **full jid** (`user@domain/resource`): idle time of the client, if it answers
	- a **server** (`domain`): uptime of the server

	[XEP-0012: Last Activity](https://xmpp.org/extensions/xep-0012.html)
**/
@xep(12)
class LastActivity {
	public static inline var XMLNS = "jabber:iq:last";

	/**
		Request the last activity of the entity `jid` (the server, i.e. its uptime, if `null`).
		Use `parse` to read the result.
	**/
	public static inline function getLastActivity(stream:Stream, ?jid:String, handler:Response<XML>->Void):IQ
		return stream.get(XMLNS, jid ?? stream.domain, handler);

	/**
		Parses a last activity `<query/>` element, returns `null` if the `seconds` attribute is missing or invalid.
	**/
	@:noUsing
	public static function parse(xml:XML):Null<TLastActivity> {
		final seconds = Std.parseInt(xml.get("seconds"));
		if (seconds == null || seconds < 0)
			return null;
		final status:String = xml.text;
		return (status == null || status.length == 0) ? {seconds: seconds} : {seconds: seconds, status: status};
	}

	/**
		Answer last activity requests to this client with its idle time in seconds.

		This reveals when the user was last active: clients MUST allow users to disable it
		(requests are answered with `service-unavailable` if this is not used).
		An entity answering requests MUST advertise the `XMLNS` feature in its service discovery responses.
	**/
	@:noUsing
	public static function handleRequests(stream:Stream, idleSeconds:() -> Int) {
		stream.features.set(XMLNS, (iq, respond) -> {
			if (iq.type != Get) {
				respond(EResponse.Error(new xmpp.Stanza.Error(cancel, bad_request)));
				return;
			}
			final seconds = idleSeconds();
			respond(EResponse.Result(Payload.create(XMLNS).set("seconds", Std.string(seconds < 0 ? 0 : seconds))));
		});
	}
}
