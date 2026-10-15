package xmpp;

import xmpp.IQ;

/**
	Moderators of a room retract the messages of other occupants: the room sends a retraction (see
	`MessageRetraction.getRetraction`, `moderated`) to all occupants.

	Messages are referred to by the `stanza-id` assigned by the room (see `StanzaId`): rooms supporting moderation
	announce `XMLNS` and assign stanza ids (e.g. Prosody's `mod_muc_moderation` with `mod_muc_mam`).

	@see [XEP-0425: Moderated Message Retraction](https://xmpp.org/extensions/xep-0425.html)
**/
@xep(425)
class MessageModeration {
	public static inline var XMLNS = "urn:xmpp:message-moderate:1";

	/**
		Asks `room` (its bare jid) to retract the message with the `stanza-id` `id`, with an optional `reason` shown to
		the occupants. The room answers with an error if you are no moderator (`forbidden`), or doesn't know the message.
	**/
	public static function moderate(stream:Stream, room:String, id:String, ?reason:String, handler:Response<XML>->Void):IQ {
		final xml:XML = Payload.create(XMLNS, "moderate");
		xml.set("id", id);
		xml.append(XML.create("retract").set("xmlns", MessageRetraction.XMLNS));
		if (reason != null && reason.length > 0)
			xml.append(XML.create("reason", reason));
		return stream.set(xml, room, handler);
	}
}
