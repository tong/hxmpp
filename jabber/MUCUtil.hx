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

//TODO ereg for debug and real

/**
	Static methods for parsing of mutliuser chat addresses.
*/
class MUCUtil {
	
	public static var EREG = ~/[A-Z0-9._%-]+@[A-Z0-9.-]+(\/[A-Z0-9._%-]+)?/i;
	public static var EREG_FULL = ~/[A-Z0-9._%-]+@[A-Z0-9.-]+\/[A-Z0-9._%-]+/i;
	
	/**
		Returns Bool if the given string is a valid muchat address.
	*/
	public static inline function isValid( t : String ) : Bool {
		return EREG.match( t );
	}
	
	/**
		Returns Bool if the given string is a full valid muchat address (including occupant name).
	*/
	public static inline  function isValidFull( t : String ) : Bool {
		return EREG_FULL.match( t );
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
	public inline static function getHost( t : String ) : String {
		return getParts( t )[1];
	}
	
	/**
		Returns the occupant name of the muc jid.
	*/
	public static function getOccupant( t : String ) : String {
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
