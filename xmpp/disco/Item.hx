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
package xmpp.disco;

class Item {
	
	public var jid : String;
	public var name : String;
	public var node : String;
	
	public function new( jid : String, ?name : String, ?node : String ) {
		this.jid = jid;
		this.name = name;
		this.node = node;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "item" );
		x.set( "jid", jid );
		if( name != null ) x.set( "name", name );
		if( node != null ) x.set( "node", node );
		return x;
	}
	
	public static inline function parse( x : Xml ) : Item {
		return new Item( x.get( "jid" ), x.get( "name" ), x.get( "node" ) );
	}
	
}
