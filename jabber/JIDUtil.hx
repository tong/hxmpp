package jabber;

//TODO move to package "jabber"

/**
	Static methods for JabberID manipulation/validation.<br>
	<a href="http://www.xmpp.org/extensions/xep-0106.html">XEP-0106: JID Escaping</a><br>
*/	
class JIDUtil {
	
	#if JABBER_DEBUG
	public static var ereg = ~/[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z][A-Z][A-Z]?/i;
	#else
	public static var ereg = ~/[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z][A-Z][A-Z]?+(\/[A-Z0-9])?/i;
	#end
	
	/**
		Returns true if the given JID is valid formed.
	*/
	public static function isValid( jid : String ) : Bool {
		if( !ereg.match( jid ) )
			return false;
		for( p in getParts( jid ) )
			if( p.length > jabber.JID.MAX_PART_SIZE )
				return false;
		return true;
	}
	
	
	/**
		Returns the node of the given jid.
	*/
	public static inline function parseNode( jid : String ) : String {
		return jid.substr( 0, jid.indexOf( "@" ) );
	}
	
	
	/**
		Returns the domain of the given jid.
	*/
	public static function parseDomain( jid : String ) : String {
		var i1 = jid.indexOf( "@" ) + 1;
		var i2 = jid.indexOf( "/" );
		if( i2 == -1 ) return jid.substr( i1 );
		return jid.substr( i1, i2-i1 );
	}
	
	
	/**
		Returns the resource of the given jid.
	*/
	public static function parseResource( jid : String ) : String {
		var i = jid.indexOf( "/" );
		if( i != -1 ) return jid.substr( i+1  );
		return null;
	}
	
	/**
		Removes the resource from a jid.
	*/
	public static function parseBar( jid : String ) : String {
		var i = jid.indexOf( "/" );
		if( i != -1 ) return jid.substr( 0, i );
		return jid;
	}
	
	
	/**
		Returns [true] if the given jid has a valid resource.
	*/
	public static inline function hasResource( jid : String ) : Bool {
		return jid.indexOf( "/" ) != -1;
	}
	
	
	/**
     	Returns a String array with parsed node, domain and resource.
    */
	public static function getParts( jid : String ) : Array<String> {
		var p : Array<String> = [ parseNode( jid ), parseDomain( jid ) ];
		if( hasResource( jid ) ) p.push( parseResource( jid ) );
		return p;
	}

	
	/**
	    Escapes the node portion of a JID according to "JID Escaping" (XEP-0106).
	    Escaping replaces characters prohibited by node-prep with escape sequences,
	    
	    Typically, escaping is performed only by a client that is processing information
	    provided by a human user in unescaped form, or by a gateway to some external system
	    (e.g., email or LDAP) that needs to generate a JID.
	    
	    TODO check XEP!! maybe minor errors (?) .. replace by regexp ?
    */
	public static function escapeNode( n : String ) : String {
		var b = new StringBuf();
		for( i in 0...n.length ) {
			var c = n.charAt( i );
			switch( c ) {
				case '"' 	: b.add( "\\22" );
				case '&' 	: b.add( "\\26" );
				case '\\' 	: b.add( "\\27" );
				case '/' 	: b.add( "\\2f" ); // TODO:check xep!
				case ':' 	: b.add( "\\3a" );
				case '<' 	: b.add( "\\3c" );
				case '>' 	: b.add( "\\3e" );
				case '@' 	: b.add( "\\40" );
				case '\\\\'	: b.add( "\\5c" );
				//TODO
				/*
				case " " : b.add( "\\20" );
				default : b.add( c );
				*/
				default : if( c == " " ) b.add( "\\20" ) else b.add( c );
			}
		}
		return b.toString();
	}


    /**
     	Un-escapes the node portion of a JID according to "JID Escaping" (XEP-0106 )
     	Escaping replaces characters prohibited by node-prep with escape sequences,
     
     	Typically, unescaping is performed only by a client that wants to display JIDs
     	containing escaped characters to a human user, or by a gateway to some
     	external system (e.g., email or LDAP) that needs to generate identifiers
     	for foreign systems.
     	
      TODO check XEP!! maybe minor errors (?) .. replace by regexp ?
    */
	public static function unescapeNode( n : String ) : String {
		var l = n.length;
		var b = new StringBuf();
		var i = 0;
		while( i < l ) {
			var c = n.charAt( i );
			if( c == '\\' && i+2 < l ) {
				var c2 = n.charAt( i+1 );
				var c3 = n.charAt( i+2 );
				if( c2 == "2" ) {
					switch( c3 ) {
						case '0' : b.add( ' ' );  i += 3;
						case '2' : b.add( '"' );  i += 3;
						case '6' : b.add( '&' );  i += 3;
						case '7' : b.add( '\\');  i += 3;
						case 'f' : b.add( '/' );  i += 3;
					}
				} else if( c2 == '3' ) {
					switch( c3 ) {
						case 'a' : b.add( ':' ); i += 3;
						case 'c' : b.add( '<' ); i += 3;
						case 'e' : b.add( '>' ); i += 3;
					}
				} else if( c2 == '4' ) {
					if( c3 == '0' ) {
						b.add( '@' );
						i += 3;
					}
				} else if( c2 == '5' ) {
					if( c3 == 'c' ) {
						b.add( '\\\\' );
						i += 4;
					}
				}
			} else {
				b.add( c );
				i++;
			}	
		}
		return b.toString();
	}
	
}
