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

class PrivacyList {
	
	public var name : String;
	public var items : Array<xmpp.privacylist.Item>;
	
	public function new( name : String ) {
		this.name = name;
		items = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "list" );
		x.set( "name", name );
		for( i in items ) x.addChild( i.toXml() );
		return x;	
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	public static function parse( x : Xml ) : xmpp.PrivacyList {
		var p = new xmpp.PrivacyList( x.get( "name" ) );
		for( e in x.elementsNamed( "item" ) )
			p.items.push( xmpp.privacylist.Item.parse( e ) );
		return p;
	}
	
}
