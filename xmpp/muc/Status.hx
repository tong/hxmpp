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
package xmpp.muc;

class Status {
	
	public static inline var MYSELF = 110;
	public static inline var ROOMNICK_CHANGED = 210;
	public static inline var WAITS_FOR_UNLOCK = 201;
	
	public var code : Int;
	
	public function new( code : Int ) {
		this.code = code;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "status" );
		x.set( "code", Std.string( code ) );
		return x;
	}
	
	public static function parse( x ) : Status {
		return new Status( Std.parseInt( x.get( "code" ) ) );
	}
	
}
