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
package xmpp.privacylist;

class Item {
	
	public var type : ItemType;
	public var action : Action;
	public var value : String;
	public var order : Int;
	
	public function new( action : Action, ?type : ItemType, ?value : String, ?order : Int = -1 ) {
		this.type = type;
		this.action = action;
		this.value = value;
		this.order = order;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "item" );
		x.set( "action", Type.enumConstructor( action ) );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		if( value != null ) x.set( "value", value );
		if( order != -1 ) x.set( "order", Std.string( order ) );
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	public static function parse( x : Xml ) : xmpp.privacylist.Item {
		var _order = x.get( "order" );
		var order = ( _order == null ) ? -1 : Std.parseInt( _order );
		var _type =  x.get( "type" );
		return new Item( Type.createEnum( Action, x.get( "action" ) ),
						 if( _type != null ) Type.createEnum( ItemType, _type ) else null,
						 x.get( "value" ),
						 order );
	}
	
}
