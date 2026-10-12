package xmpp;

/**
	Random data from the platform's secure random source.

	Sources: `crypto.randomBytes` (nodejs), `crypto.getRandomValues` (js), `/dev/urandom` (sys targets on unix-like systems).
	Where none is available (e.g. sys targets on Windows) it falls back to `Std.random`, which is **not** secure.
**/
class Random {
	/**
		Returns `length` random bytes.
	**/
	public static function bytes(length:Int):haxe.io.Bytes {
		#if nodejs
		return js.node.Crypto.randomBytes(length).hxToBytes();
		#elseif js
		final a = new js.lib.Uint8Array(length);
		js.Syntax.code("globalThis.crypto.getRandomValues({0})", a);
		return haxe.io.Bytes.ofData(a.buffer);
		#elseif sys
		if (sys.FileSystem.exists('/dev/urandom')) {
			final i = sys.io.File.read('/dev/urandom');
			final b = i.read(length);
			i.close();
			return b;
		}
		#end
		final b = haxe.io.Bytes.alloc(length);
		for (i in 0...length)
			b.set(i, Std.random(256));
		return b;
	}
}
