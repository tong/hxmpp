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

class Items extends List<xmpp.disco.Item> {

	public static var XMLNS = xmpp.NS.PROTOCOL+'/disco#items';
	
	public var node : String;
	
	public function new( ?node : String ) {
		super();
		this.node = node;
	}
	
	public function toXml() : Xml {
		var q = xmpp.IQ.createQueryXml( XMLNS );
		if( node != null ) q.set( "node", node );
		if( !isEmpty() ) {
			for( i in iterator() ) {
				var item = Xml.createElement( 'item' );
				if( i.jid != null ) item.set( "jid", i.jid );
				if( i.name != null ) item.set( "name", i.name );
				q.addChild( item );
			}
		}
		return q;
	}
	
	public static function parse( x : Xml ) : Items {
		var items = new Items( x.get( "node" ) );
		/*
		for( f in x.elements() ) {
			switch( f.nodeName ) {
			case "item" : items.add( xmpp.disco.Item.parse( f ) );
			}
		}
		*/
		for( f in x.elementsNamed( "item" ) )
			items.add( xmpp.disco.Item.parse( f ) );
		return items;
	}

}
