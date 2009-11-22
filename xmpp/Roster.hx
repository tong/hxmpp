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

/**
	IQ roster extension.
*/
class Roster extends List<xmpp.roster.Item> {
	
	public static inline var XMLNS = "jabber:iq:roster";
	
	public function new( ?items : Iterable<xmpp.roster.Item> ) {
		super();
		if( items != null )
			for( i in items )
				add( i );
	}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS );
		for( i in iterator() )
			x.addChild( i.toXml() );
		return x;
	}
	
	public override function toString() : String {
		return toXml().toString();
	}
	
	public static function parse( x : Xml ) : xmpp.Roster {
		var r = new xmpp.Roster();
		for( e in x.elementsNamed( "item" ) )
			r.add( xmpp.roster.Item.parse( e ) );
		return r;
	}
	
}
