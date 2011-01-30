/*
 *	This file is part of HXMPP.
 *	Copyright (c)2009 http://www.disktree.net
 *	
 *	HXMPP is free software: you can redistribute it and/or modify
 *  it under the terms of the GNU Lesser General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  HXMPP is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.
 *	See the GNU Lesser General Public License for more details.
 *
 *  You should have received a copy of the GNU Lesser General Public License
 *  along with HXMPP. If not, see <http://www.gnu.org/licenses/>.
*/
package jabber;

/**
	Static methods for JabberID manipulation/validation.
*/	
class JIDUtil {
	
	public static inline var MIN_LENGTH = 8;
	public static inline var MAX_PARTSIZE = 1023;
	public static inline var MAX_SIZE = 3071;
	
	/**
		Regular expression matching a valid JID
	*/
	public static var EREG = 
		#if JABBER_DEBUG
		~/([A-Z0-9._%-]+)@([A-Z0-9.-]+(\.[A-Z][A-Z][A-Z]?)?)(\/([A-Z0-9._%-]+))?/i;
		#else
		~/([A-Z0-9._%-]+)@([A-Z0-9.-]+\.[A-Z][A-Z][A-Z]?)(\/([A-Z0-9._%-]+))?/i;
		#end
	
	/**
		@return True if the given JID is valid formed.
	*/
	public static function isValid( t : String ) : Bool {
		if( t == null || t.length < MIN_LENGTH || t.length > MAX_SIZE )
			return false;
		if( !EREG.match( t ) )
			return false;
		for( p in getParts( t ) )
			if( p.length > MAX_PARTSIZE )
				return false;
		return true;
	}
	
	/**
		@returns The node of the given JID.
	*/
	public static inline function parseNode( t : String ) : String {
		return t.substr( 0, t.indexOf( "@" ) );
	}
	
	/**
		@returns The domain of the given JID.
	*/
	public static function parseDomain( t : String ) : String {
		var i1 = t.indexOf( "@" ) + 1;
		var i2 = t.indexOf( "/" );
		return ( i2 == -1 ) ? t.substr( i1 ) : t.substr( i1, i2-i1 );
	}
	
	/**
		@returns The resource of the given JID.
	*/
	public static function parseResource( t : String ) : String {
		var i = t.indexOf( "/" );
		return ( i == -1 ) ? null : t.substr( i+1  );
	}
	
	/**
		Removes The resource from a JID.
	*/
	public static function parseBare( t : String ) : String {
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
	public static function getParts( jid : String ) : Array<String> {
		var p : Array<String> = [ parseNode( jid ), parseDomain( jid ) ];
		if( hasResource( jid ) ) p.push( parseResource( jid ) );
		return p;
	}
	
	/**
		Splits the given JID into parts and returns it as array excluding the resource.
	*/
	public static function splitBare( jid : String ) : Array<String> {
		var i = jid.indexOf( "/" );
		return ( i == -1 ) ? [jid] : [ jid.substr( 0, i ), jid.substr( i+1 ) ];
	}
	
	/**
	    Escapes the node portion of a JID according to "JID Escaping" (XEP-0106).<br/>
	    Escaping replaces characters prohibited by node-prep with escape sequences.
	    <br/>
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
     	Un-escapes the node portion of a JID according to "JID Escaping" (<a href="http://www.xmpp.org/extensions/xep-0106.html">XEP-0106: JID Escaping</a>).<br/>
     	Escaping replaces characters prohibited by node-prep with escape sequences.
     	<br/>
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
	
}
