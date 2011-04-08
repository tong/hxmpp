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
package xmpp.filter;

/**
	Filters XMPP packets where a packet object field matches a given value.
*/
class PacketFieldFilter {
	
	public var name : String;
	public var value : String;
//	public var attributes : Array<String>;
	
	public function new( name : String, ?value : String ) {
		this.name = name;
		this.value = value;
	}
	
	@:keep public function accept( p : xmpp.Packet ) : Bool {
		/* hmmm cpp bug
		if( !Reflect.hasField( p, name ) )
			return false;
		*/
		var v = Reflect.field( p, name );
		if( v == null )
			return false;
			
		/*
		if( value == null ) return true;
		return Reflect.field( p, name ) == value;
		*/
		return ( value == null ) ? true : ( v == value );
	}
	
}
