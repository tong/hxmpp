package xmpp;

using StringTools;

/**
	Unique jabber identifier.

	A `Jid` is made up of a **node** (generally a username), a **domain**, and a **resource**.

	The first two parts are demarcated by the `@` character used as a separator and
	the last two parts are similarly demarcated by the `/` character (e.g., `juliet@example.com/balcony`).

		jid             = [ node `@` ] domain [ `/` resource ]
		domain          = fqdn / address-literal
		fqdn            = (sub-domain 1*(`.` sub-domain))
		sub-domain      = (internationalized domain label)
		address-literal = IPv4address / IPv6address

	Each allowable portion of a jid must not be more than 1023 bytes in length,
	resulting in a maximum total size (including the `@` and `/` separators) of 3071 bytes.

	Node and domain are case-insensitive, the resource is case-sensitive:
	`==` compares normalized jids (see `normalize`).

	- [Extensible Messaging and Presence Protocol: Address Format](https://tools.ietf.org/html/rfc7622)
	- [XEP-0106: JID Escaping](https://xmpp.org/extensions/xep-0106.html)
**/
@:nullSafety
@:forward(node, domain, resource)
abstract Jid(CJid) from CJid {
	public static inline var MAX_PARTSIZE = 1023;
	public static inline var MAX_SIZE = 3071;

	@:deprecated("Jid.EREG only matches ASCII jids with node, use Jid.isValid")
	public static final EREG = ~/^(([A-Z0-9._%-]{1,1023})@([A-Z0-9._%-]{1,1023})((?:\/)([A-Z0-9._%-]{1,1023}))?)$/i;

	public inline function new(?node:Null<String>, domain:String, ?resource:Null<String>)
		this = new CJid(node, domain, resource);

	public function getBare():String {
		return (this.node == null) ? this.domain : this.node + '@' + this.domain;
	}

	@:to public function toString():String {
		var s = getBare();
		if (this.resource != null)
			s += '/' + this.resource;
		return s;
	}

	@:to public inline function toArray():Array<Null<String>>
		return [this.node, this.domain, this.resource];

	/**
		Returns `true` if both jids are equal, ignoring the case of node and domain.
	**/
	public function equals(jid:Null<Jid>):Bool {
		// Compare the underlying objects, `==` and `!=` of Jid are overloaded
		final other:Null<CJid> = cast jid;
		if (other == null)
			return false;
		final o:Jid = other;
		return normalize(toString()) == normalize(o.toString());
	}

	@:op(A == B) static function eq(a:Null<Jid>, b:Null<Jid>):Bool {
		final x:Null<CJid> = cast a;
		final y:Null<CJid> = cast b;
		if (x == null || y == null)
			return x == y;
		final j:Jid = x;
		return j.equals(y);
	}

	@:op(A != B) static inline function neq(a:Null<Jid>, b:Null<Jid>):Bool
		return !eq(a, b);

	@:arrayAccess function getPart(i:Int):String {
		return switch i {
			case 0: this.node;
			case 1: this.domain;
			case 2: this.resource;
			default: toString();
		}
	}

	@:arrayAccess function setPart(i:Int, str:String) {
		switch i {
			case 0:
				this.node = str;
			case 1:
				this.domain = str;
			case 2:
				this.resource = str;
			default:
		}
	}

	@:from public static inline function fromArray(arr:Array<String>):Jid
		return new Jid(arr[0], arr[1], arr[2]);

	/**
		Parses a jid, `null` if `str` is `null`.
	**/
	@:from public static function fromString(str:Null<String>):Null<Jid> {
		if (str == null)
			return null;
		final p = split(str);
		return new Jid(p.node, p.domain, p.resource);
	}

	/**
		Returns the jid with node and domain in lowercase, for comparing jids.

		This approximates the [RFC 7622](https://tools.ietf.org/html/rfc7622) preparation of node and domain
		(the full PRECIS profiles are not applied); the resource is case-sensitive and kept as is.
	**/
	public static function normalize(str:String):String {
		final p = split(str);
		var s = p.domain.toLowerCase();
		if (p.node != null)
			s = p.node.toLowerCase() + '@' + s;
		if (p.resource != null)
			s += '/' + p.resource;
		return s;
	}

	/**
		Returns `true` if the given string is a valid jid.

		Checks the structure and length limits of [RFC 7622](https://tools.ietf.org/html/rfc7622),
		but does not apply the full PRECIS profiles.
	**/
	#if python
	// Haxe 4 null safety rejects EReg.match on python ("Cannot assign nullable value here"); not needed with Haxe 5
	@:nullSafety(Off)
	#end
	public static function isValid(str:String):Bool {
		if (str == null || str.length == 0 || byteLength(str) > MAX_SIZE)
			return false;
		final p = split(str);
		final node = p.node;
		final domain = p.domain;
		final resource = p.resource;
		if (node != null && (!isValidPart(node) || ~/[\s"&'\/:<>@]/.match(node)))
			return false;
		if (!isValidPart(domain) || ~/[\s@]/.match(domain))
			return false;
		if (resource != null && !isValidPart(resource))
			return false;
		return true;
	}

	static function isValidPart(part:String):Bool
		return part.length > 0 && byteLength(part) <= MAX_PARTSIZE;

	static inline function byteLength(str:String):Int
		return haxe.io.Bytes.ofString(str).length;

	public static function parseNode(str:String):Null<String> {
		return split(str).node;
	}

	public static function parseDomain(str:String):String {
		return split(str).domain;
	}

	public static function parseResource(str:String):Null<String> {
		return split(str).resource;
	}

	public static function parseBare(str:String):String {
		final p = split(str);
		return (p.node == null) ? p.domain : p.node + '@' + p.domain;
	}

	/**
		Splits the given string into `[node, domain, resource]`; `node` and `resource` are `null` if absent.

		The resource is everything after the first `/`, so it may contain `@` and `/`.
	**/
	public static function parseParts(str:String):Array<Null<String>> {
		final p = split(str);
		return [p.node, p.domain, p.resource];
	}

	static function split(str:String):{node:Null<String>, domain:String, resource:Null<String>} {
		final slash = str.indexOf("/");
		final bare = (slash == -1) ? str : str.substr(0, slash);
		final at = bare.indexOf("@");
		return {
			node: (at == -1) ? null : bare.substr(0, at),
			domain: bare.substr(at + 1),
			resource: (slash == -1) ? null : str.substr(slash + 1)
		};
	}

	/** Characters escaped by XEP-0106 and their escape sequences **/
	static final ESCAPES = [
		" " => "20", "\"" => "22", "&" => "26", "'" => "27", "/" => "2f",
		":" => "3a", "<" => "3c", ">" => "3e", "@" => "40", "\\" => "5c"
	];

	/**
		Escapes the node portion of a JID according to [XEP-0106: JID Escaping](https://xmpp.org/extensions/xep-0106.html).

		Characters disallowed in a node are replaced with escape sequences (e.g. `\20` for a space).
		A `\` is only escaped if followed by an escape sequence; leading and trailing spaces are removed.

		Typically, escaping is performed only by a client that is processing information
		provided by a human user in unescaped form, or by a gateway to some external system
		(e.g., email or LDAP) that needs to generate a JID.
	**/
	@xep(106)
	public static function escapeNode(s:String):String {
		var start = 0;
		var end = s.length;
		while (start < end && s.charAt(start) == " ")
			start++;
		while (end > start && s.charAt(end - 1) == " ")
			end--;
		final buf = new StringBuf();
		for (i in start...end) {
			final c = s.charAt(i);
			if (c == "\\") {
				final seq = s.substr(i + 1, 2);
				buf.add(isEscapeSequence(seq) ? "\\5c" : c);
			} else {
				final e = ESCAPES.get(c);
				buf.add(e == null ? c : "\\" + e);
			}
		}
		return buf.toString();
	}

	/**
		Un-escapes the node portion of a JID according to [XEP-0106: JID Escaping](https://xmpp.org/extensions/xep-0106.html).

		Only the defined escape sequences are replaced.

		Typically, unescaping is performed only by a client that wants to display JIDs
		containing escaped characters to a human user, or by a gateway to some
		external system (e.g., email or LDAP) that needs to generate identifiers
		for foreign systems.
	**/
	@xep(106)
	public static function unescapeNode(s:String):String {
		final buf = new StringBuf();
		var i = 0;
		while (i < s.length) {
			final c = s.charAt(i);
			final seq = s.substr(i + 1, 2);
			if (c == "\\" && isEscapeSequence(seq)) {
				for (k => v in ESCAPES)
					if (v == seq) {
						buf.add(k);
						break;
					}
				i += 3;
			} else {
				buf.add(c);
				i++;
			}
		}
		return buf.toString();
	}

	static function isEscapeSequence(seq:String):Bool {
		for (v in ESCAPES)
			if (v == seq)
				return true;
		return false;
	}
}

@:structInit private class CJid {
	public var node:Null<String>;
	public var domain:String;
	public var resource:Null<String>;

	@:allow(xmpp.Jid)
	inline function new(?node:String, domain:String, ?resource:String) {
		this.node = node;
		this.domain = domain;
		this.resource = resource;
	}
}
