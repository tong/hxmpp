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
package xmpp.pubsub;

class Retract extends List<Item> {
		
	public var node : String;
	public var notify : Bool;
	
	public function new( node : String, ?itemIDs : Iterable<String>, ?notify : Bool = false ) {
		super();
		this.node = node;
		if( itemIDs != null )
			for( id in itemIDs ) add( new Item( id ) );
		this.notify = notify;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "retract" );
		x.set( "node", node );
		if( notify ) x.set( "notify", "true" );
		for( i in iterator() )
			x.addChild( i.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Retract {
		var _n = x.get( "notify" );
		var r = new Retract( x.get( "node" ), if( _n != null && ( _n == "true" || _n == "1" ) ) true else false );
		for( e in x.elementsNamed( "item" ) )
			r.add( Item.parse( e ) );
		return r;
	}
	
}
