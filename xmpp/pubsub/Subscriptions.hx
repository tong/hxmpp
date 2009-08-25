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

class Subscriptions extends List<Subscription> {
	
	public var node : String;
	
	public function new( ?node : String ) {
		super();
		this.node = node;
	}
	
	public function toXml() {
		var x = Xml.createElement( "subscriptions" );
		if( node != null ) x.set( "node", node );
		for( s in iterator() )
			x.addChild( s.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : Subscriptions {
		var s = new Subscriptions( x.get( "node" ) );
		for( e in x.elementsNamed( "subscription" ) )
			s.add( Subscription.parse( e ) );
		return s;
	}
	
}
