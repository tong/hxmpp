package xmpp;

/**
	Universally unique identifiers (UUIDs).

	[RFC 4122: A Universally Unique IDentifier (UUID) URN Namespace](https://www.rfc-editor.org/rfc/rfc4122)
**/
class Uuid {
	/**
		Returns a random (version 4) UUID, e.g. `f47ac10b-58cc-4372-a567-0e02b2c3d479`.
	**/
	public static function make():String {
		final b = Random.bytes(16);
		b.set(6, (b.get(6) & 0x0f) | 0x40); // version 4
		b.set(8, (b.get(8) & 0x3f) | 0x80); // variant 10xx
		final h = b.toHex();
		return h.substr(0, 8) + '-' + h.substr(8, 4) + '-' + h.substr(12, 4) + '-' + h.substr(16, 4) + '-' + h.substr(20);
	}

	/**
		Returns `true` if `uuid` is a version 4 UUID (case-insensitive).
	**/
	public static function isValid(uuid:Null<String>):Bool {
		return uuid != null && ~/^[0-9a-f]{8}-[0-9a-f]{4}-4[0-9a-f]{3}-[89ab][0-9a-f]{3}-[0-9a-f]{12}$/i.match(uuid);
	}
}
