package xmpp;

using StringTools;

/**
    Unique jabber identifier.

    A JID is made up of a node (generally a username), a domain, and a resource.
        jid             = [ node "@" ] domain [ "/" resource ]
        domain          = fqdn / address-literal
        fqdn            = (sub-domain 1*("." sub-domain))
        sub-domain      = (internationalized domain label)
        address-literal = IPv4address / IPv6address

    Each allowable portion of a jid (node, domain, and resource) must not be more than 1023 bytes in length,
    resulting in a maximum total size (including the '@' and '/' separators) of 3071 bytes.
*/
@:forward(
    node,domain,resource,
    getBare,toString,toArray,
    fromArray,parse
)
abstract JID(JIDType) from JIDType to JIDType {

	public static inline var MIN_LENGTH = 8;
	public static inline var MAX_PARTSIZE = 1023;
	public static inline var MAX_SIZE = 3071;

	/**
		Regular expression matching a valid JID

		//TODO
	*/
	public static var EREG(default,null) = ~/^(([A-Z0-9._%-]{1,1023})@([A-Z0-9._%-]{1,1023})((?:\/)([A-Z0-9._%-]{1,1023}))?)$/i;

    public inline function new( jid : JIDType ) this = jid;

    @:to public inline function toString() : String
		return this.toString();

    @:to public inline function toArray() : Array<String>
		return this.toArray();

	@:from public static inline function fromArray( a : Array<String> ) : JID
	    return new JIDType( a[0], a[1], a[2] );

	@:from public static inline function parse( s : String ) : JID
        return fromArray( parseParts( s ) );

	public static inline function create( ?node : String, ?domain : String, ?resource : String ) : JID
		return new JID( new JIDType( node, domain, resource ) );

    /**
        Returns true if the given JID is valid.
    */
    public static function isValid( str : String ) : Bool {
        if( str == null || str.length < MIN_LENGTH || str.length > MAX_SIZE )
            return false;
		if( !EREG.match( str ) )
            return false;
			/*
		for( i in 2...5 ) {
			var part = EREG.matched(i);
			if( part.length > MAX_PARTSIZE )
				return false;
		}
        for( p in parseParts( str ) )
            if( p.length > MAX_PARTSIZE )
                return false;
				*/
        return true;
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

	public static function compare( a : JID, b : JID ) : Bool {
		if( a.node != b.node ) return false;
		if( a.domain != b.domain ) return false;
		if( a.resource != b.resource ) return false;
		return true;
	}

    /**
		Escapes the node portion of a JID according to "JID Escaping" (XEP-0106).
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
		Un-escapes the node portion of a JID according to XEP-0106:JID Escaping (http://www.xmpp.org/extensions/xep-0106.html).
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

private class JIDType {

    public var node : String;
    public var domain : String;
    public var resource : String;

    public inline function new( ?node : String, ?domain : String, ?resource : String ) {
        this.node = node;
        this.domain = domain;
        this.resource = resource;
    }

    public function getBare() : String {
		if( node == null || domain == null )
			return null;
        return node + '@' + domain;
    }

    public function toString() : String {
        var s = getBare();
        if( resource != null ) s += '/$resource';
        return s;
    }

    public inline function toArray() : Array<String> {
        return [node,domain,resource];
    }

	/*
    public static inline function fromArray( a : Array<String> ) : JIDType {
        return new JIDType( a[0], a[1], a[2] );
    }

    public static function parse( str : String ) : JIDType {
        var i = str.indexOf( "@" );
        if( i == -1 )
            throw 'invalid jid';
            //throw InvalidJid();
		var j = str.indexOf( "/" );
        var node = str.substr( 0, i );
        var domain : String = null;
        var resource : String = null;
        if( j == -1 ) {
            domain = str.substr( i+1 );
        } else {
            domain = str.substring( i+1, j );
            resource = str.substr( j+1 );
        }
        return new JIDType( node, domain, resource );
    }
	*/
}
