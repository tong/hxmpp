package xmpp;

import haxe.io.Bytes;

/**
	Incremental hash of data given in parts (e.g. a file read block by block): `sha-1` and `sha-256`, the names of
	[XEP-0300](https://xmpp.org/extensions/xep-0300.html).

		final d = Digest.create("sha-256");
		d.update(block1);
		d.update(block2);
		final hash = d.finish();

	Native on python, nodejs and php (64-bit integers), else in Haxe.
**/
class Digest {
	/** The algorithms supported **/
	public static final ALGORITHMS = ["sha-1", "sha-256"];

	/** Bytes hashed so far **/
	public var length(default, null):Float = 0;

	public final algo:String;

	#if python
	final native:Dynamic;
	#elseif nodejs
	final native:js.node.crypto.Hash;
	#elseif php
	final native:Dynamic;
	#else

	/** The current block, `used` bytes of it filled **/
	final block = Bytes.alloc(64);

	var used = 0;

	/** The state: 5 words (sha-1) or 8 (sha-256) **/
	final h:Array<Int>;

	/** The message schedule **/
	final w:Array<Int>;
	#end

	/** A digest of `algo` (`sha-1`, `sha-256`), `null` if the algorithm is not supported **/
	public static function create(algo:String):Null<Digest>
		return ALGORITHMS.contains(algo) ? new Digest(algo) : null;

	/** The hash of `data` with `algo`, `null` if the algorithm is not supported **/
	public static function make(data:Bytes, algo:String):Null<Bytes> {
		final d = create(algo);
		if (d == null)
			return null;
		d.update(data);
		return d.finish();
	}

	function new(algo:String) {
		this.algo = algo;
		#if python
		native = python.Syntax.code("__import__('hashlib').new({0})", algo == "sha-1" ? "sha1" : "sha256");
		#elseif nodejs
		native = js.node.Crypto.createHash(algo == "sha-1" ? "sha1" : "sha256");
		#elseif php
		native = php.Syntax.code("hash_init({0})", algo == "sha-1" ? "sha1" : "sha256");
		#else
		h = (algo == "sha-1") ? [0x67452301, 0xEFCDAB89, 0x98BADCFE, 0x10325476, 0xC3D2E1F0] : [
			0x6A09E667,
			0xBB67AE85,
			0x3C6EF372,
			0xA54FF53A,
			0x510E527F,
			0x9B05688C,
			0x1F83D9AB,
			0x5BE0CD19
		];
		w = [for (_ in 0...(algo == "sha-1" ? 80 : 64)) 0];
		#end
	}

	/** Adds `len` bytes of `data` from `pos` (all by default) **/
	public function update(data:Bytes, pos = 0, ?len:Int) {
		len ??= data.length - pos;
		length += len;
		#if python
		python.Syntax.code("{0}.update({1}[{2}:{2} + {3}])", native, data.getData(), pos, len);
		#elseif nodejs
		native.update(js.node.Buffer.hxFromBytes(data.sub(pos, len)));
		#elseif php
		php.Syntax.code("hash_update({0}, {1})", native, data.getString(pos, len, RawNative));
		#else
		var p = pos;
		final end = pos + len;
		while (p < end) {
			final n = Std.int(Math.min(64 - used, end - p));
			block.blit(used, data, p, n);
			used += n;
			p += n;
			if (used == 64) {
				compress();
				used = 0;
			}
		}
		#end
	}

	/** The hash of all data added; the digest can't be used afterwards **/
	public function finish():Bytes {
		#if python
		return Bytes.ofData(python.Syntax.code("bytearray({0}.digest())", native));
		#elseif nodejs
		return native.digest().hxToBytes();
		#elseif php
		return Bytes.ofString(php.Syntax.code("hash_final({0}, true)", native), RawNative);
		#else
		// padding: 0x80, zeros, the length in bits (64 bits, big endian)
		final bits = length * 8;
		final high = Std.int(bits / 4294967296.0), low = Std.int(bits - high * 4294967296.0);
		block.set(used++, 0x80);
		if (used > 56) {
			block.fill(used, 64 - used, 0);
			compress();
			used = 0;
		}
		block.fill(used, 56 - used, 0);
		setInt(block, 56, high);
		setInt(block, 60, low);
		compress();
		final out = Bytes.alloc(h.length * 4);
		for (i in 0...h.length)
			setInt(out, i * 4, h[i]);
		return out;
		#end
	}

	#if !(python || nodejs || php)
	static final K256 = [
		0x428A2F98, 0x71374491, 0xB5C0FBCF, 0xE9B5DBA5, 0x3956C25B, 0x59F111F1, 0x923F82A4, 0xAB1C5ED5, 0xD807AA98, 0x12835B01, 0x243185BE, 0x550C7DC3,
		0x72BE5D74, 0x80DEB1FE, 0x9BDC06A7, 0xC19BF174, 0xE49B69C1, 0xEFBE4786, 0x0FC19DC6, 0x240CA1CC, 0x2DE92C6F, 0x4A7484AA, 0x5CB0A9DC, 0x76F988DA,
		0x983E5152, 0xA831C66D, 0xB00327C8, 0xBF597FC7, 0xC6E00BF3, 0xD5A79147, 0x06CA6351, 0x14292967, 0x27B70A85, 0x2E1B2138, 0x4D2C6DFC, 0x53380D13,
		0x650A7354, 0x766A0ABB, 0x81C2C92E, 0x92722C85, 0xA2BFE8A1, 0xA81A664B, 0xC24B8B70, 0xC76C51A3, 0xD192E819, 0xD6990624, 0xF40E3585, 0x106AA070,
		0x19A4C116, 0x1E376C08, 0x2748774C, 0x34B0BCB5, 0x391C0CB3, 0x4ED8AA4A, 0x5B9CCA4F, 0x682E6FF3, 0x748F82EE, 0x78A5636F, 0x84C87814, 0x8CC70208,
		0x90BEFFFA, 0xA4506CEB, 0xBEF9A3F7, 0xC67178F2
	];

	/** 32-bit addition (also where Int is no 32-bit integer, e.g. js) **/
	static inline function add(a:Int, b:Int):Int
		return (a + b) | 0;

	static inline function rotl(x:Int, n:Int):Int
		return (x << n) | (x >>> (32 - n));

	static inline function rotr(x:Int, n:Int):Int
		return (x >>> n) | (x << (32 - n));

	static inline function getInt(b:Bytes, pos:Int):Int
		return (b.get(pos) << 24) | (b.get(pos + 1) << 16) | (b.get(pos + 2) << 8) | b.get(pos + 3);

	static inline function setInt(b:Bytes, pos:Int, v:Int) {
		b.set(pos, (v >>> 24) & 0xFF);
		b.set(pos + 1, (v >>> 16) & 0xFF);
		b.set(pos + 2, (v >>> 8) & 0xFF);
		b.set(pos + 3, v & 0xFF);
	}

	/** Processes the full block **/
	function compress()
		if (h.length == 5)
			sha1()
		else
			sha256();

	function sha1() {
		for (i in 0...16)
			w[i] = getInt(block, i * 4);
		for (i in 16...80)
			w[i] = rotl(w[i - 3] ^ w[i - 8] ^ w[i - 14] ^ w[i - 16], 1);
		var a = h[0], b = h[1], c = h[2], d = h[3], e = h[4];
		for (i in 0...80) {
			final f = if (i < 20) (b & c) | (~b & d) else if (i < 40) b ^ c ^ d else if (i < 60) (b & c) | (b & d) | (c & d) else b ^ c ^ d;
			final k = if (i < 20) 0x5A827999 else if (i < 40) 0x6ED9EBA1 else if (i < 60) 0x8F1BBCDC else 0xCA62C1D6;
			final t = add(add(add(rotl(a, 5), f), add(e, k)), w[i]);
			e = d;
			d = c;
			c = rotl(b, 30);
			b = a;
			a = t;
		}
		h[0] = add(h[0], a);
		h[1] = add(h[1], b);
		h[2] = add(h[2], c);
		h[3] = add(h[3], d);
		h[4] = add(h[4], e);
	}

	function sha256() {
		for (i in 0...16)
			w[i] = getInt(block, i * 4);
		for (i in 16...64) {
			final s0 = rotr(w[i - 15], 7) ^ rotr(w[i - 15], 18) ^ (w[i - 15] >>> 3);
			final s1 = rotr(w[i - 2], 17) ^ rotr(w[i - 2], 19) ^ (w[i - 2] >>> 10);
			w[i] = add(add(w[i - 16], s0), add(w[i - 7], s1));
		}
		var a = h[0], b = h[1], c = h[2], d = h[3], e = h[4], f = h[5], g = h[6], hh = h[7];
		for (i in 0...64) {
			final s1 = rotr(e, 6) ^ rotr(e, 11) ^ rotr(e, 25);
			final ch = (e & f) ^ (~e & g);
			final t1 = add(add(add(hh, s1), add(ch, K256[i])), w[i]);
			final s0 = rotr(a, 2) ^ rotr(a, 13) ^ rotr(a, 22);
			final maj = (a & b) ^ (a & c) ^ (b & c);
			final t2 = add(s0, maj);
			hh = g;
			g = f;
			f = e;
			e = add(d, t1);
			d = c;
			c = b;
			b = a;
			a = add(t1, t2);
		}
		h[0] = add(h[0], a);
		h[1] = add(h[1], b);
		h[2] = add(h[2], c);
		h[3] = add(h[3], d);
		h[4] = add(h[4], e);
		h[5] = add(h[5], f);
		h[6] = add(h[6], g);
		h[7] = add(h[7], hh);
	}
	#end
}
