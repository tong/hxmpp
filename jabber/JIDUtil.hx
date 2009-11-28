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
	Static methods for JabberID manipulation/validation.<br/>
	<a href="http://www.xmpp.org/extensions/xep-0106.html">XEP-0106: JID Escaping</a><br/>
*/	
class JIDUtil {
	
	#if JABBER_DEBUG
	public static var EREG = ~/[A-Z0-9._%-]+@[A-Z0-9.-]+(\.[A-Z]{3}?)?(\/[A-Z0-9._%-])?/i;
	#else
	public static var EREG = ~/[A-Z0-9._%-]+@[A-Z0-9.-]+\.[A-Z]{3}?(\/[A-Z0-9._%-])?/i;
	#end

	/**
		Returns true if the given JID is valid formed.
	*/
	public static function isValid( t : String ) : Bool {
		if( !EREG.match( t ) )
			return false;
		for( p in getParts( t ) )
			if( p.length > jabber.JID.MAX_PART_SIZE )
				return false;
		return true;
	}
	
	/**
		Returns the node of the given JID.
	*/
	public static inline function parseNode( t : String ) : String {
		return t.substr( 0, t.indexOf( "@" ) );
	}
	
	/**
		Returns the domain of the given JID.
	*/
	public static function parseDomain( t : String ) : String {
		var i1 = t.indexOf( "@" ) + 1;
		var i2 = t.indexOf( "/" );
		if( i2 == -1 ) return t.substr( i1 );
		return t.substr( i1, i2-i1 );
	}
	
	/**
		Returns the resource of the given JID.
	*/
	public static function parseResource( t : String ) : String {
		var i = t.indexOf( "/" );
		if( i != -1 ) return t.substr( i+1  );
		return null;
	}
	
	/**
		Removes the resource from a JID.
	*/
	public static function parseBare( t : String ) : String {
		var i = t.indexOf( "/" );
		if( i != -1 ) return t.substr( 0, i );
		return t;
	}
	
	/**
		Returns true if the given JID has a valid resource.
	*/
	public static inline function hasResource( t : String ) : Bool {
		return t.indexOf( "/" ) != -1;
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
		<p>
	    Escapes the node portion of a JID according to "JID Escaping" (XEP-0106).<br/>
	    Escaping replaces characters prohibited by node-prep with escape sequences.
	    <p/>
	    <p>
	    Typically, escaping is performed only by a client that is processing information
	    provided by a human user in unescaped form, or by a gateway to some external system
	    (e.g., email or LDAP) that needs to generate a JID.
	    </p>
	    
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
    	<p>
     	Un-escapes the node portion of a JID according to "JID Escaping" (XEP-0106 ).<br/>
     	Escaping replaces characters prohibited by node-prep with escape sequences.
     	</p>
     	<p>
     	Typically, unescaping is performed only by a client that wants to display JIDs
     	containing escaped characters to a human user, or by a gateway to some
     	external system (e.g., email or LDAP) that needs to generate identifiers
     	for foreign systems.
     	</p>
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
