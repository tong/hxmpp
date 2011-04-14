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

class Items extends List<Item> {
	
	public var node : String;
	public var subid : String;
	public var maxItems : Null<Int>;
	
	public function new( ?node : String, ?subid :String, ?maxItems : Int ) {
		super();
		this.node = node;
		this.subid = subid;
		this.maxItems = maxItems;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "items" );
		if( node != null ) x.set( "node", node );
		if( subid != null ) x.set( "subid", subid );
		if( maxItems != null ) x.set( "max_items", Std.string( maxItems ) );
		for( i in iterator() )
			x.addChild( i.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Items {
		var max = x.get( "maxItems" );
		var i = new Items( x.get( "node" ), x.get( "subid" ),
						   if( max != null ) Std.parseInt( max ) );
		for( e in x.elementsNamed( "item" ) )
			i.add( Item.parse( e ) );
		return i;
	}
	
}
