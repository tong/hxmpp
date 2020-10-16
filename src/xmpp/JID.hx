package xmpp;

using StringTools;

private class JIDType {

    public var node : String;
    public var domain : String;
    public var resource : String;

    @:allow(xmpp.JID)
    inline function new( ?node : String, domain : String, ?resource : String ) {
        this.node = node;
        this.domain = domain;
        this.resource = resource;
    }
}

/**

	Unique jabber identifier.

	A JID is made up of a **node** (generally a username), a **domain**, and a **resource**.

	The first two parts are demarcated by the `@` character used as a separator and
	the last two parts are similarly demarcated by the `/` character (e.g., `juliet@example.com/balcony`).

		jid             = [ node "@" ] domain [ "/" resource ]
		domain          = fqdn / address-literal
		fqdn            = (sub-domain 1*("." sub-domain))
		sub-domain      = (internationalized domain label)
		address-literal = IPv4address / IPv6address

	Each allowable portion of a jid must not be more than 1023 bytes in length,
	resulting in a maximum total size (including the `@` and `/` separators) of 3071 bytes.

	- [Extensible Messaging and Presence Protocol: Address Format](https://tools.ietf.org/html/rfc7622)
	- [XEP-0106: JID Escaping](https://xmpp.org/extensions/xep-0106.html)

**/
@:forward(node,domain,resource)
abstract JID(JIDType) from JIDType to JIDType {

	//public static inline var MIN_LENGTH = 8;
	public static inline var MAX_PARTSIZE = 1023;
	public static inline var MAX_SIZE = 3071;

	public static var EREG(default,null) = ~/^(([A-Z0-9._%-]{1,1023})@([A-Z0-9._%-]{1,1023})((?:\/)([A-Z0-9._%-]{1,1023}))?)$/i;

    public inline function new( ?node : String, domain : String, ?resource : String  )
        this = new JIDType( node, domain, resource );

    public function getBare() : String {
		return (this.node == null || this.domain == null) ? null : this.node+'@'+this.domain;
    }

    @:to public function toString() : String {
        var s = getBare();
        if( this.resource != null ) s += '/'+this.resource;
        return s;
    }

    @:to public inline function toArray() : Array<String>
        return [this.node,this.domain,this.resource];

	@:op(A==B) public function equals( jid : JID ) : Bool {
		if( this.node != jid.node ) return false;
        if( this.domain != jid.domain ) return false;
        if( this.resource != jid.resource ) return false;
        return true;
	}

	@:arrayAccess function getPart( i : Int ) : String {
		return switch i {
		case 0: this.node;
		case 1: this.domain;
		case 2: this.resource;
		default: toString();
		}
	}
	
	@:arrayAccess function setPart( i : Int, str : String ) {
		switch i {
		case 0: this.node = str;
		case 1: this.domain = str;
		case 2: this.resource = str;
		default:
		}
	}

	@:from public static inline function fromArray( arr : Array<String> ) : JID
	    return new JIDType( arr[0], arr[1], arr[2] );

	@:from public static inline function fromString( str : String ) : JID
        return fromArray( parseParts( str ) );

    /**
        Returns `true` if the given string is a valid jid.
    */
    public static function isValid( str : String ) : Bool {
        //if( str == null || str.length < MIN_LENGTH || str.length > MAX_SIZE )
        if( str == null || str.length > MAX_SIZE )
            return false;
        if( !EREG.match( str ) )
            return false;
        return true;
    }

    public static inline function parseNode( str : String ) : String {
        return str.substr( 0, str.indexOf( "@" ) );
    }

    public static function parseDomain( str : String ) : String {
        var a = str.indexOf( "@" );
        var b = str.indexOf( "/" );
        //var a = [str.substr( 0, i )];
        return (b == -1) ? str.substr( a+1 ) : str.substr( a+1, b-a-1 );
    }

    public static function parseResource( str : String ) : String {
        var i = str.indexOf( "/" );
        return (i == -1) ? null : str.substr( i+1  );
    }

    public static function parseBare( str : String ) : String {
        var a = parseParts( str );
        return a[0] +'@'+ a[1];
    }

    public static function parseParts( str : String ) : Array<String> {
        var i = str.indexOf( "@" );
        var j = str.indexOf( "/" );
        var a = [str.substr( 0, i )];
        return a.concat( (j == -1) ? [str.substring( i+1 )] : [str.substring( i+1, j ),str.substr( j+1 )] );
    }

	/**
		Escapes the node portion of a JID according to [XEP-0106:JID Escaping](https://xmpp.org/extensions/xep-0106.html).
		Escaping replaces characters prohibited by node-prep with escape sequences.

		Typically, escaping is performed only by a client that is processing information
		provided by a human user in unescaped form, or by a gateway to some external system
		(e.g., email or LDAP) that needs to generate a JID.
	*/
    public static function escapeNode( s : String ) : String {
        //s.split("&").join("&amp;")
        s = s.replace( "\\", "\\5c" );
        s = s.replace( " ", "\\20" );
        s = s.replace( "\"", "\\22" );
        s = s.replace( "&", "\\26" );
        s = s.replace( "'", "\\27" );
        s = s.replace( "/", "\\2f" );
        s = s.replace( ":", "\\3a" );
        s = s.replace( "<", "\\3c" );
        s = s.replace( ">", "\\3e" );
        s = s.replace( "@", "\\40" );
        return s;
    }

	/**
		Un-escapes the node portion of a JID according to [XEP-0106:JID Escaping](https://xmpp.org/extensions/xep-0106.html).
		Escaping replaces characters prohibited by node-prep with escape sequences.

		Typically, unescaping is performed only by a client that wants to display JIDs
		containing escaped characters to a human user, or by a gateway to some
		external system (e.g., email or LDAP) that needs to generate identifiers
		for foreign systems.
	*/
    public static function unescapeNode( s : String ) : String {
        s = s.replace( "\\20", " " );
        s = s.replace( "\\22", "\"" );
        s = s.replace( "\\26", "&" );
        s = s.replace( "\\27", "'" );
        s = s.replace( "\\2f", "/");
        s = s.replace( "\\3a", ":" );
        s = s.replace( "\\3c", "<");
        s = s.replace( "\\3e", ">" );
        s = s.replace( "\\40", "@" );
        s = s.replace( "\\5c", "\\" );
        return s;
    }
}
