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
package xmpp;

class X {
	
	public static function create( xmlns : String, ?childs : Iterable<Xml> ) : Xml {
		var x = Xml.createElement( "x" );
		x.set( "xmlns", xmlns );
		if( childs != null ) 
			for( c in childs )
				x.addChild( c );
		return x;
	}
	
	/*
	public static function parse( x : Xml ) { xmlns : String, attributes : Array<Xml>, childs : Array<Xml> } {
	}
	*/
}
