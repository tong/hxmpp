package xmpp;

/**
	The hash of the avatar in the vCard (its `PHOTO`), announced in presences: contacts load the vCard when it changes.
	Older than PEP avatars (`UserAvatar`), still used by many clients; servers may convert between both.

	@see [XEP-0153: vCard-Based Avatars](https://xmpp.org/extensions/xep-0153.html)
**/
@xep(153)
class VCardAvatar {
	public static inline var XMLNS = "vcard-temp:x:update";

	/**
		The hash (SHA-1, hex) of the avatar announced in `presence`: `""` if the user has none, `null` if the presence
		doesn't announce one (the client doesn't know it yet, or doesn't support it).
	**/
	public static function getPhotoHash(presence:Presence):Null<String> {
		for (e in presence.properties) {
			if (e.name != "x" || !e.is(XMLNS))
				continue;
			final photo = e.elements.named("photo")[0];
			if (photo == null)
				return null;
			final text:Null<String> = photo.text;
			return StringTools.trim(text ?? "").toLowerCase();
		}
		return null;
	}

	/** Announces the hash of the own avatar in `presence` (`""`: none, `null`: not known yet) **/
	public static function setPhotoHash(presence:Presence, ?hash:String):Presence {
		for (e in presence.properties.copy())
			if (e.name == "x" && e.is(XMLNS))
				presence.properties.remove(e);
		final x = XML.create("x").set("xmlns", XMLNS);
		if (hash != null)
			x.append(XML.create("photo", (hash.length > 0) ? hash : null));
		presence.properties.push(x);
		return presence;
	}
}
