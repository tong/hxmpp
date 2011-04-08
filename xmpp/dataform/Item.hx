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
package xmpp.dataform;

class Item {
	
	public var fields : Array<Field>;
	
	public function new( ?fields : Array<Field> ) {
		this.fields = ( fields != null ) ?fields : new Array<Field>();
	}
	
	public function toXml() : Xml {
		return createXml( "item" );
	}
	
	function createXml( n : String ) : Xml {
		var x = Xml.createElement( n );
		for( f in fields ) x.addChild( f.toXml() );
		return x;
	}
	
	public static inline function parse( x : Xml ) : Item {
		return cast Field.parseFields( new Item(), x );
	}
	
}
