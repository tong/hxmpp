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

class MUCAdmin {
	
	public static var XMLNS = xmpp.MUC.XMLNS+"#admin";
	
	public var items : Array<xmpp.muc.Item>;
	
	public function new() {
		items = new Array();
	}

	public function toXml() : Xml {
		var x = Xml.createElement( "query" );
		x.set( "xmlns", XMLNS );
		for( i in items ) x.addChild( i.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.MUCAdmin {
		var p = new MUCAdmin();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "item" : p.items.push( xmpp.muc.Item.parse( e ) );	
			}
		}
		return p;
	}
	
}
