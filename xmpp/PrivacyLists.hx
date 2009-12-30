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
*/
class PrivacyLists {
	
	public static var XMLNS = "jabber:iq:privacy";
	
	public var active : String;
	public var _default : String;
	public var list : Array<xmpp.PrivacyList>;

	public function new() {
		list = new Array();
	}
	
	public function toXml() : Xml {
		var q = xmpp.IQ.createQueryXml( XMLNS );
		if( active != null ) {
			var e = Xml.createElement( "active" );
			if( active != "" ) e.set( "name", active );
			q.addChild( e );
		}
		if( _default != null ) {
			var e = Xml.createElement( "default" );
			e.set( "name", _default );
			q.addChild( e );
		}
		for( l in list ) q.addChild( l.toXml() );
		return q;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	public function iterator() : Iterator<PrivacyList> {
		return list.iterator();
	}
	
	public static function parse( x : Xml ) : xmpp.PrivacyLists {
		var p = new xmpp.PrivacyLists();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
				case "active" : p.active = e.get( "name" );
				case "default" : p._default = e.get( "name" );
				case "list" : p.list.push( xmpp.PrivacyList.parse( e ) );
			}
		}
		return p;
	}
	
}
