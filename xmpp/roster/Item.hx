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
package xmpp.roster;

import xmpp.XMLUtil;

class Item {
	
	public var jid(default,null) : String;
	public var subscription : Subscription;
	public var name : String;
	public var askType : AskType;
	public var groups : List<String>;
	
	public function new( jid : String,
						 ?subscription : Subscription, ?name : String, ?askType : AskType, ?groups : Iterable<String> ) {
		this.jid = jid;
		this.subscription = subscription;
		this.name = name;
		this.askType = askType;
		this.groups = ( groups != null ) ? Lambda.list( groups ) : new List();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "item" );
		x.set( "jid", jid );
		if( name != null ) x.set( "name", name );
		if( subscription != null ) x.set( "subscription", Type.enumConstructor( subscription ) );
		if( askType != null ) x.set( "ask", Type.enumConstructor( askType ) );
		for( g in groups )
			x.addChild( XMLUtil.createElement( "group", g ) );
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.roster.Item {
		var i = new Item( x.get( "jid" ) );
		var _sub = x.get( "subscription" );
		if( _sub != null ) i.subscription = Type.createEnum( Subscription, _sub );
		i.name = x.get( "name" );
		var _ask = x.get( "ask" );
		if( _ask != null ) i.askType = Type.createEnum( AskType, _ask );
		for( g in x.elementsNamed( "group" ) )
			i.groups.add( g.firstChild().nodeValue );
		return i;
	}
	
}
