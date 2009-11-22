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

class BlockList {
	
	public static inline var XMLNS = "urn:xmpp:blocking";
	
	public var items : Array<String>;
	public var unblock : Bool;
	
	public function new( ?items : Array<String>, ?unblock : Bool = false ) {
		this.items = ( items != null ) ? items : new Array();
		this.unblock = unblock;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( unblock ? "unblock" : "block" );
		x.set( "xmlns", XMLNS );
		for( i in items ) {
			var e = Xml.createElement( "item" );
			e.set( "jid", i );
			x.addChild( e );
		}
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.BlockList {
		var l = new BlockList();
		for( e in x.elements() )
			l.items.push( e.get( "jid" ) );
		return l;
	}
			
}
