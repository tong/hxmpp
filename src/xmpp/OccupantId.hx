package xmpp;

/**
	A stable id of an occupant of a room, added by the room to the occupant's messages and presences: the same
	across nickname changes and rejoins (of the same account), unlike the nick. E.g. to tell whether a correction,
	retraction or reaction comes from the author of the message.

	Trust it only if the room announces support (`XMLNS` in its service discovery features): such a room removes the
	ids senders add themselves, other rooms pass them on, so anybody could claim the id of another.

		final id = OccupantId.get(message.properties);

	@see [XEP-0421: Occupant identifiers for semi-anonymous MUCs](https://xmpp.org/extensions/xep-0421.html)
**/
@xep(421)
class OccupantId {
	public static inline var XMLNS = "urn:xmpp:occupant-id:0";

	/**
		Returns the occupant id in `properties` (of a message or presence from a room), `null` if there is none.
	**/
	public static function get(properties:Array<XML>):Null<String> {
		for (e in properties)
			if (e.name == "occupant-id" && e.is(XMLNS) && e.get("id") != null && e.get("id").length > 0)
				return e.get("id");
		return null;
	}
}
