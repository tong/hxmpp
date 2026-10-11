package xmpp;

/**
	Universally unique identifier.

	128-bit label used for information.
**/
class Uuid {
	/**
		Returns a random (version 4) UUID, e.g. `f47ac10b-58cc-4372-a567-0e02b2c3d479`.
	**/
	public static function make():String {
		final b = @:privateAccess Stream.randomBytes(16);
		b.set(6, (b.get(6) & 0x0f) | 0x40); // version 4
		b.set(8, (b.get(8) & 0x3f) | 0x80); // variant 10xx
		final h = b.toHex();
		return h.substr(0, 8) + '-' + h.substr(8, 4) + '-' + h.substr(12, 4) + '-' + h.substr(16, 4) + '-' + h.substr(20);
	}

	public static inline function rint(max:Int):Int
		return Math.floor(Math.random() * max);

	public static inline function rchar():String
		return "0123456789abcdef".charAt(rint(0x10));

	public static function rstring(length:Int):String {
		var s = new StringBuf();
		for (_ in 0...length)
			s.add(rchar());
		return s.toString();
	}
	/**
		Returns `true` if the passed `uuid` conforms to the UUID v.4 format.
	**/
	// public static function isValid( uuid : String ) : Bool {
	// 	return ~/^[0123456789abcdef]{8}-[0123456789abcdef]{4}-4[0123456789abcdef]{3}-[89ab][0123456789abcdef]{3}-[0123456789abcdef]{12}$/i.match(uuid);
	// }
}
