/*
 * Copyright (c), disktree
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package jabber;

/**
	Static methods for jabber-id validation and manipulation.
*/	
class JIDUtil {
	
	public static inline var MIN_LENGTH = 8;
	public static inline var MAX_PARTSIZE = 1023;
	public static inline var MAX_SIZE = 3071;
	
	/**
		Regular expression matching a valid JID
	*/
	public static var EREG = 
		#if jabber_debug
		~/([A-Z0-9._%-]+)@([A-Z0-9\.-]+)(\/([A-Z0-9._%-]+))?/i;
		#else
		~/([A-Z0-9._%-]+)@([A-Z0-9.-]+\.[A-Z][A-Z][A-Z]?)(\/([A-Z0-9._%-]+))?/i;
		#end
	
	/**
		@returns True if the given JID is valid formed.
	*/
	public static function isValid( t : String ) : Bool {
		if( t == null 
			#if !jabber_debug
			|| t.length < MIN_LENGTH || t.length > MAX_SIZE
			#end )
			return false;
		if( !EREG.match( t ) )
			return false;
		for( p in parts( t ) )
			if( p.length > MAX_PARTSIZE )
				return false;
		return true;
	}
	
	/**
		@returns The node of the given JID.
	*/
	public static inline function node( t : String ) : String {
		return t.substr( 0, t.indexOf( "@" ) );
	}
	
	/**
		@returns The domain of the given JID.
	*/
	public static function domain( t : String ) : String {
		var i1 = t.indexOf( "@" ) + 1;
		var i2 = t.indexOf( "/" );
		return ( i2 == -1 ) ? t.substr( i1 ) : t.substr( i1, i2-i1 );
	}
	
	/**
		@returns The resource of the given JID.
	*/
	public static function resource( t : String ) : String {
		var i = t.indexOf( "/" );
		return ( i == -1 ) ? null : t.substr( i+1  );
	}
	
	/**
		Removes The resource from a JID.
	*/
	public static function bare( t : String ) : String {
		var i = t.indexOf( "/" );
		return ( i == -1 ) ? t : t.substr( 0, i );
	}
	
	/**
		@returns True if the given JID has a valid resource.
	*/
	public static inline function hasResource( t : String ) : Bool {
		return t.indexOf( "/" ) != -1;
	}
	
	/**
     	@returns A String array with parsed node, domain and resource.
    */
	public static function parts( jid : String ) : Array<String> {
		var p : Array<String> = [ node( jid ), domain( jid ) ];
		if( hasResource( jid ) ) p.push( resource( jid ) );
		return p;
	}
	
	/**
		Splits the given JID into parts and returns it as array excluding the resource.
	*/
	public static function splitBare( jid : String ) : Array<String> {
		var i = jid.indexOf( "/" );
		return ( i == -1 ) ? [jid] : [ jid.substr( 0, i ), jid.substr( i+1 ) ];
	}
	
	//TODO remove
	/**
	*/
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
	public static function escapeNode( n : String ) : String {
		//s.split("&").join("&amp;")
		n = StringTools.replace( n, "\\", "\\5c" );
		n = StringTools.replace( n, " ", "\\20" );
		n = StringTools.replace( n, "\"", "\\22" );
		n = StringTools.replace( n, "&", "\\26" );
		n = StringTools.replace( n, "'", "\\27" );
		n = StringTools.replace( n, "/", "\\2f" );
		n = StringTools.replace( n, ":", "\\3a" );
		n = StringTools.replace( n, "<", "\\3c" );
		n = StringTools.replace( n, ">", "\\3e" );
		n = StringTools.replace( n, "@", "\\40" );
		return n;
	}

    /**
     	Un-escapes the node portion of a JID according to XEP-0106:JID Escaping (http://www.xmpp.org/extensions/xep-0106.html).
     	Escaping replaces characters prohibited by node-prep with escape sequences.

     	Typically, unescaping is performed only by a client that wants to display JIDs
     	containing escaped characters to a human user, or by a gateway to some
     	external system (e.g., email or LDAP) that needs to generate identifiers
     	for foreign systems.
    */
	public static function unescapeNode( n : String ) : String {
		n = StringTools.replace( n, "\\20", " " );
		n = StringTools.replace( n, "\\22", "\"" );
		n = StringTools.replace( n, "\\26", "&" );
		n = StringTools.replace( n, "\\27", "'" );
		n = StringTools.replace( n, "\\2f", "/");
		n = StringTools.replace( n, "\\3a", ":" );
		n = StringTools.replace( n, "\\3c", "<");
		n = StringTools.replace( n, "\\3e", ">" );
		n = StringTools.replace( n, "\\40", "@" );
		n = StringTools.replace( n, "\\5c", "\\" );
		return n;
	}
	
	//TODO
		
	/*
	/**
		Build a jid string from constact parts at compile time
	macro public static function create( node : String, domain : String, resource : String ) {
	}
	*/
	
}
