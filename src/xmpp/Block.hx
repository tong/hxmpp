package xmpp;

import xmpp.IQ;
import xmpp.Response.EResponse;

/**
	Block communication with other entities.

	Requests are handled by the own server. After a change the server pushes it to all resources
	that requested the block list, handle these with `handlePushes`.

	[XEP-0191: Blocking Command](https://xmpp.org/extensions/xep-0191.html)
**/
@xep(191)
class Block {
	public static inline var XMLNS = 'urn:xmpp:blocking';

	/** Namespace of the application error condition returned when sending to a blocked entity **/
	public static inline var XMLNS_ERRORS = 'urn:xmpp:blocking:errors';

	/**
		Load the list of blocked entities, use `getItems` to read the jids from the result.
	**/
	public static inline function getBlocklist(stream:xmpp.Stream, handler:xmpp.Response<XML>->Void):IQ {
		return stream.get(Payload.create(XMLNS, "blocklist"), handler);
	}

	/**
		Block receiving stanzas from the given entities (at least one).
	**/
	public static function block(stream:xmpp.Stream, jids:Array<String>, handler:xmpp.Response<XML>->Void):IQ {
		return stream.set(createItems("block", jids), handler);
	}

	/**
		Unblock receiving stanzas from the given entities, or from all blocked entities if `jids` is `null` or empty.
	**/
	public static function unblock(stream:Stream, ?jids:Array<String>, handler:xmpp.Response<XML>->Void):IQ {
		return stream.set(createItems("unblock", jids), handler);
	}

	/**
		Returns the jids of a `<blocklist/>`, `<block/>` or `<unblock/>` element.
	**/
	public static function getItems(xml:XML):Array<String> {
		return [for (e in xml.elements) if (e.name == "item" && e.has("jid")) e.get("jid")];
	}

	/**
		Handle block list changes pushed by the server.

		`handler` is called with `blocked` = `true` for blocked jids, `false` for unblocked jids;
		empty `jids` with `blocked` = `false` means all entities were unblocked.
		Pushes not sent by the own server are rejected.
	**/
	public static function handlePushes(stream:Stream, handler:(blocked:Bool, jids:Array<String>) -> Void) {
		stream.features.set(XMLNS, (iq, respond) -> {
			if (iq.type != Set || !isFromOwnServer(stream, iq.from)) {
				respond(EResponse.Error(new xmpp.Stanza.Error(cancel, service_unavailable)));
				return;
			}
			switch iq.payload.name {
				case "block":
					respond(EResponse.Result(null));
					handler(true, getItems(iq.payload));
				case "unblock":
					respond(EResponse.Result(null));
					handler(false, getItems(iq.payload));
				default:
					respond(EResponse.Error(new xmpp.Stanza.Error(modify, bad_request)));
			}
		});
	}

	/**
		Returns `true` if the stanza error was returned because the recipient is blocked.
	**/
	public static function isBlockedError(error:Null<xmpp.Stanza.Error>):Bool {
		return error != null && error.app != null && error.app.xmlns == XMLNS_ERRORS && error.app.condition == "blocked";
	}

	static function createItems(name:String, ?jids:Array<String>):XML {
		final xml:XML = Payload.create(XMLNS, name);
		if (jids != null)
			for (jid in jids)
				xml.append(XML.create("item").set("jid", jid));
		return xml;
	}

	static function isFromOwnServer(stream:Stream, from:Null<String>):Bool {
		return from == null || (stream.jid != null && Jid.parseBare(from) == Jid.parseBare(stream.jid) && Jid.parseResource(from) == null);
	}
}
