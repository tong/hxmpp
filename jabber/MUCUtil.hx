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
	Static methods for parsing of mutliuser chat addresses.
*/
class MUCUtil {
	
	/** Regular expression matching a MUC address */
	public static var EREG = ~/([A-Z0-9._%-]+)@([A-Z0-9.-]+)(\/([A-Z0-9._%-]+))?/i;

	/**
		Returns true if the given string is a valid muchat address.<br/>
		The 'nick' parameter indicates if a full adress (including nickname) is expected.
	*/
	public static function isValid( t : String, nick : Bool = false ) : Bool {
		if( !EREG.match( t ) ) return false;
		return nick ? ( EREG.matched( 4 ) != null ) : true;
	}
	
	/**
		Returns the room of the muc jid.
	*/
	public static inline function getRoom( t : String ) : String {
		return JIDUtil.parseNode( t );
	}
	
	/**
		Returns the host of the muc jid.
	*/
	public static inline function getHost( t : String ) : String {
		return getParts( t )[1];
	}
	
	/**
		Returns the occupant name of the muc jid.
	*/
	public static function getNick( t : String ) : String {
		var i = t.indexOf( "/" );
		return ( i == -1 ) ? null : t.substr( i+1 );
	}
	
	/**
		Returns array existing of roomname[0], host[1] and (optional) occupantname[2] of the given muc address.
	*/
	public static function getParts( t : String ) : Array<String> {
		var i1 = t.indexOf( "@" );
		var i2 = t.indexOf( "/" );
		return if( i2 == -1 ) [ t.substr( 0, i1 ), t.substr( i1+1 ) ];
		else [ t.substr( 0, i1 ), t.substr( i1+1, i2-i1-1 ), t.substr( i2+1 ) ];
	}
		
}
