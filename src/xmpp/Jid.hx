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

	- [Extensible Messaging and Presence Protocol: Address Format](https://tools.ietf.org/html/rfc7622)
	- [XEP-0106: JID Escaping](https://xmpp.org/extensions/xep-0106.html)
**/
@:nullSafety
@:forward(node, domain, resource)
abstract Jid(CJid) from CJid {
	public static inline var MAX_PARTSIZE = 1023;
	public static inline var MAX_SIZE = 3071;

	public static final EREG = ~/^(([A-Z0-9._%-]{1,1023})@([A-Z0-9._%-]{1,1023})((?:\/)([A-Z0-9._%-]{1,1023}))?)$/i;

	public inline function new(?node:Null<String>, domain:String, ?resource:Null<String>)
		this = new CJid(node, domain, resource);

	public function getBare():Null<String> {
		return (this.node == null || this.domain == null) ? null : this.node + '@' + this.domain;
	}

	@:to public function toString():Null<String> {
		var s = getBare();
		if (this.resource != null)
			s += '/' + this.resource;
		return s;
	}

	@:to public inline function toArray():Array<Null<String>>
		return [this.node, this.domain, this.resource];

	@:op(A == B) public function equals(jid:Jid):Bool {
		return if (this.node != jid.node || this.domain != jid.domain || this.resource != jid.resource) false else true;
	}

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

	@:from public static inline function fromString(str:String):Jid
		return fromArray(parseParts(str));

	/**
		Returns `true` if the given string is a valid jid.
	**/
	#if python
	// TODO: HACK: python complains: Null safety: Cannot assign nullable value here.
	@:nullSafety(Off)
	#end
	public static function isValid(str:String):Bool {
		return (str == null || str.length > MAX_SIZE) ? false : EREG.match(str);
	}

	public static inline function parseNode(str:String):String {
		return str.substr(0, str.indexOf("@"));
	}

	public static function parseDomain(str:String):String {
		final a = str.indexOf("@");
		final b = str.indexOf("/");
		// var a = [str.substr( 0, i )];
		return (b == -1) ? str.substr(a + 1) : str.substr(a + 1, b - a - 1);
	}

	public static function parseResource(str:String):Null<String> {
		var i = str.indexOf("/");
		return (i == -1) ? null : str.substr(i + 1);
	}

	public static function parseBare(str:String):String {
		var a = parseParts(str);
		return a[0] + '@' + a[1];
	}

	public static function parseParts(str:String):Array<String> {
		final i = str.indexOf("@");
		final j = str.indexOf("/");
		final a = [str.substr(0, i)];
		return a.concat((j == -1) ? [str.substring(i + 1)] : [str.substring(i + 1, j), str.substr(j + 1)]);
	}

	/**
		Escapes the node portion of a JID according to [XEP-0106:JID Escaping](https://xmpp.org/extensions/xep-0106.html).
		Escaping replaces characters prohibited by node-prep with escape sequences.

		Typically, escaping is performed only by a client that is processing information
		provided by a human user in unescaped form, or by a gateway to some external system
		(e.g., email or LDAP) that needs to generate a JID.
	**/
	@xep(106)
	public static function escapeNode(s:String):String {
		// s.split("&").join("&amp;")
		return s.replace("\\", "\\5c")
			.replace(" ", "\\20")
			.replace("\"", "\\22")
			.replace("&", "\\26")
			.replace("'", "\\27")
			.replace("/", "\\2f")
			.replace(":", "\\3a")
			.replace("<", "\\3c")
			.replace(">", "\\3e")
			.replace("@", "\\40");
	}

	/**
		Un-escapes the node portion of a JID according to [XEP-0106:JID Escaping](https://xmpp.org/extensions/xep-0106.html).
		Escaping replaces characters prohibited by node-prep with escape sequences.

		Typically, unescaping is performed only by a client that wants to display JIDs
		containing escaped characters to a human user, or by a gateway to some
		external system (e.g., email or LDAP) that needs to generate identifiers
		for foreign systems.
	**/
	@xep(106)
	public static function unescapeNode(s:String):String {
		return s.replace("\\20", " ")
			.replace("\\22", "\"")
			.replace("\\26", "&")
			.replace("\\27", "'")
			.replace("\\2f", "/")
			.replace("\\3a", ":")
			.replace("\\3c", "<")
			.replace("\\3e", ">")
			.replace("\\40", "@")
			.replace("\\5c", "\\");
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
