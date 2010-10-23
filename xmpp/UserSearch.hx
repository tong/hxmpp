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

class UserSearch {
	
	public static var XMLNS = "jabber:iq:search";
	
	public var instructions : String;
	public var first : String;
	public var last : String;
	public var nick : String;
	public var email : String;
	public var items : Array<UserSearchItem>;
	public var form : DataForm;
	
	public function new() {
		items = new Array();
	}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS );
		if( instructions != null ) x.addChild( XMLUtil.createElement( "instructions", instructions ) );
		if( first != null ) x.addChild( XMLUtil.createElement( "first", first ) );
		if( last != null ) x.addChild( XMLUtil.createElement( "last", last ) );
		if( nick != null ) x.addChild( XMLUtil.createElement( "nick", nick ) );
		if( email != null ) x.addChild( XMLUtil.createElement( "email", email ) );
		for( i in items ) {
			var e = Xml.createElement( "item" );
			e.set( "jid", i.jid );
			e.addChild( XMLUtil.createElement( "first", i.first ) );
			e.addChild( XMLUtil.createElement( "last", i.last ) );
			e.addChild( XMLUtil.createElement( "nick", i.nick ) );
			e.addChild( XMLUtil.createElement( "email", i.email ) );
			x.addChild( e );
		}
		if( form != null ) x.addChild( form.toXml() );
		return x;
	}
	
	public static function parse( x : Xml ) : UserSearch {
		var s = new UserSearch();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case "instructions" : s.instructions = e.firstChild().nodeValue;
			case "first" : s.first = getFieldValue( e );
			case "last" : s.last = getFieldValue( e );
			case "nick" : s.nick = getFieldValue( e );
			case "email" : s.email = getFieldValue( e );
			case "item" :
				var i : UserSearchItem = cast { jid : e.get( "jid" ) };
				for( c in e.elements() ) {
					switch( c.nodeName ) {
					case "first" :  i.first = c.firstChild().nodeValue;
					case "last" :  i.last = c.firstChild().nodeValue;
					case "nick" :  i.nick = c.firstChild().nodeValue;
					case "email" :  i.email = c.firstChild().nodeValue;
					}
				}
				s.items.push( i );
			case "x" : s.form = DataForm.parse( e );
			}
		}
		return s;
	}
	
	static function getFieldValue( x : Xml ) : String {
		return ( x.firstChild() == null ) ? "" : x.firstChild().nodeValue;
	}
	
}
