package xmpp;

import haxe.io.Bytes;
import haxe.io.BytesBuffer;

using StringTools;

@:structInit private class URIType {
	/** The jid to interact with, e.g. `romeo@montague.net` **/
	public var jid:String;

	/** The query type, e.g. `message`, `join` or `roster` **/
	public var action:String;

	/** The account to use for the interaction (authority component, `xmpp://account/jid`) **/
	public var account:String;

	/** Parameters of the query, e.g. `body` of a `message` action **/
	public var params:Map<String, String>;
}

/**
	XMPP Uniform Resource Identifiers (URIs), e.g. `xmpp:romeo@montague.net?message;body=Hi`.

	Components are percent-decoded when parsing and percent-encoded (UTF-8) when converting to a string.

	[RFC 5122: Internationalized Resource Identifiers (IRIs) and Uniform Resource Identifiers (URIs) for XMPP](https://xmpp.org/rfcs/rfc5122.html)
**/
@:forward
abstract URI(URIType) from URIType to URIType {
	/** Characters not encoded in the jid **/
	static inline var PATH_CHARS = "@/!$&'()*+,:=";

	/** Characters not encoded in the account **/
	static inline var ACCOUNT_CHARS = "@!$&'()*+,:=";

	/** Characters not encoded in query keys and values **/
	static inline var QUERY_CHARS = "!$'()*+,:@/";

	public inline function clone():URI {
		return {
			jid: this.jid,
			action: this.action,
			account: this.account,
			params: [for (k => v in this.params) k => v]
		}
	}

	public function equalsTo(uri:Null<URI>):Bool {
		final other:Null<URIType> = cast uri;
		if (other == null)
			return false;
		if (this.jid != other.jid || this.action != other.action || this.account != other.account
			|| Lambda.count(this.params) != Lambda.count(other.params))
			return false;
		for (a => b in this.params)
			if (other.params.get(a) != b)
				return false;
		return true;
	}

	/**
		Returns the URI string; parameters are sorted by key.
	**/
	@:to public function toString():String {
		var s = 'xmpp:';
		if (this.account != null)
			s += '//${encode(this.account, ACCOUNT_CHARS)}/';
		if (this.jid != null)
			s += encode(this.jid, PATH_CHARS);
		if (this.action != null) {
			s += '?' + encode(this.action, QUERY_CHARS);
			if (this.params != null) {
				final keys = [for (k in this.params.keys()) k];
				keys.sort((a, b) -> a < b ? -1 : a > b ? 1 : 0);
				for (k in keys)
					s += ';${encode(k, QUERY_CHARS)}=${encode(this.params.get(k), QUERY_CHARS)}';
			}
		}
		return s;
	}

	@:op(A == B) public static function equals(self:Null<URI>, that:Null<URI>):Bool {
		final a:Null<URIType> = cast self;
		final b:Null<URIType> = cast that;
		return (a == null || b == null) ? a == b : (a : URI).equalsTo(b);
	}

	@:op(A != B) public static inline function notEquals(self:Null<URI>, that:Null<URI>):Bool
		return !equals(self, that);

	@:from public static inline function fromString(s:String):URI
		return parse(s);

	/**
		Parses `xmpp:[//account/]jid[?action[;key=value]*]`, returns `null` if invalid.
	**/
	public static function parse(str:String):URI {
		if (str == null || !str.startsWith('xmpp:'))
			return null;
		var rest = str.substr(5);
		var account:String = null;
		if (rest.startsWith('//')) {
			rest = rest.substr(2);
			final slash = rest.indexOf('/');
			account = (slash == -1) ? rest : rest.substr(0, slash);
			rest = (slash == -1) ? '' : rest.substr(slash + 1);
		}
		final hash = rest.indexOf('#');
		if (hash != -1)
			rest = rest.substr(0, hash);
		final r:URI = {
			jid: null,
			action: null,
			account: (account == null) ? null : decode(account),
			params: [],
		};
		final i = rest.indexOf('?');
		final path = (i == -1) ? rest : rest.substr(0, i);
		if (path.length > 0)
			r.jid = decode(path);
		if (i != -1) {
			final params = rest.substr(i + 1).split(';');
			r.action = decode(params.shift());
			for (p in params) {
				final j = p.indexOf('=');
				if (j == -1)
					r.params.set(decode(p), '');
				else
					r.params.set(decode(p.substr(0, j)), decode(p.substr(j + 1)));
			}
		}
		return r;
	}

	/**
		Percent-encodes the UTF-8 bytes of `s`, except unreserved characters and `allowed`.
	**/
	static function encode(s:String, allowed:String):String {
		final buf = new StringBuf();
		final bytes = Bytes.ofString(s);
		for (i in 0...bytes.length) {
			final b = bytes.get(i);
			final c = String.fromCharCode(b);
			if ((b >= 'A'.code && b <= 'Z'.code) || (b >= 'a'.code && b <= 'z'.code) || (b >= '0'.code && b <= '9'.code)
				|| b == '-'.code || b == '.'.code || b == '_'.code || b == '~'.code || (b < 128 && allowed.indexOf(c) != -1))
				buf.add(c);
			else
				buf.add('%' + StringTools.hex(b, 2));
		}
		return buf.toString();
	}

	/**
		Decodes percent-encoded UTF-8 bytes of `s`; `+` is kept (no form encoding).
	**/
	static function decode(s:String):String {
		final buf = new BytesBuffer();
		var start = 0;
		var i = 0;
		while (i < s.length) {
			if (s.charCodeAt(i) == '%'.code && i + 2 < s.length && isHex(s.charCodeAt(i + 1)) && isHex(s.charCodeAt(i + 2))) {
				// copy the unencoded text as a whole, to keep characters outside the BMP intact
				buf.add(Bytes.ofString(s.substring(start, i)));
				buf.addByte(Std.parseInt('0x' + s.substr(i + 1, 2)));
				i += 3;
				start = i;
			} else
				i++;
		}
		buf.add(Bytes.ofString(s.substring(start)));
		return buf.getBytes().toString();
	}

	static function isHex(c:Null<Int>):Bool
		return c != null && ((c >= '0'.code && c <= '9'.code) || (c >= 'a'.code && c <= 'f'.code) || (c >= 'A'.code && c <= 'F'.code));
}
