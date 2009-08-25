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

class Item {
	
	public var jid(default,null) : String;
	public var subscription : Subscription;
	public var name : String;
	public var askType : AskType;
	public var groups : List<String>;
	
	public function new( jid : String,
						 ?subscription : Subscription, ?name : String, ?askType : AskType, ?groups : List<String> ) {
		this.jid = jid;
		this.subscription = subscription;
		this.name = name;
		this.askType = askType;
		this.groups = ( groups != null ) ? groups : new List();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "item" );
		x.set( "jid", jid );
		if( name != null ) x.set( "name", name );
		if( subscription != null ) x.set( "subscription", Type.enumConstructor( subscription ) );
		if( askType != null ) x.set( "ask", Type.enumConstructor( askType ) );
		for( group in groups )
			x.addChild( util.XmlUtil.createElement( "group", group ) );
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}

	public static function parse( x : Xml ) : xmpp.roster.Item {
		var i = new Item( x.get( "jid" ) );
		i.subscription = Type.createEnum( Subscription, x.get( "subscription" ) );
		i.name = x.get( "name" );
		if( x.exists( "ask" ) ) i.askType = Type.createEnum( AskType, x.get( "ask" ) );
		for( g in x.elementsNamed( "group" ) )
			i.groups.add( g.firstChild().nodeValue );
		return i;
	}
	
}
