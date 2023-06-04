package xmpp;

/**
    Universally unique identifier.

    128-bit label used for information.
**/
class Uuid {

	/**
		Returns a string value representing a UUID value.
	**/
	public static function make() : String {
		var s = [];
		for(i in 0...8) s[i] = randomChar();
		s[8] = '-';
		for(i in 9...13) s[i] = randomChar();
		s[13] = '-';
		s[14] = '4';
		for(i in 15...18) s[i] = randomChar();
		s[18] = '-';
		s[19] = "89AB".charAt(randomInt(0x3));
		for(i in 20...23) s[i] = randomChar();
		s[23] = '-';
		for(i in 24...36) s[i] = randomChar();
		return s.join('');
	}

	public static inline function randomInt(max:Int) : Int
		return Math.floor(Math.random() * max);

	public static inline function randomChar() : String
		return "0123456789abcdef".charAt(randomInt(0x10));

	public static function randomString(length: Int) : String {
        var s = new StringBuf();
        for(_ in 0...length) s.add(randomChar());
        return s.toString();
    }
	/**
		Returns `true` if the passed `uuid` conforms to the UUID v.4 format.
	**/
	// public static function isValidUuid(str : String) : Bool {
	// 	return ~/^[0123456789abcdef]{8}-[0123456789abcdef]{4}-4[0123456789abcdef]{3}-[89ab][0123456789abcdef]{3}-[0123456789abcdef]{12}$/i.match(str);
	// }
}
