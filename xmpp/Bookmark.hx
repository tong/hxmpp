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

using xmpp.XMLUtil;

private typedef Conference = {
	var jid : String;
	var name : String;
	var nick : String;
	var autojoin : Null<Bool>;
	/** NOT RECOMMENDED */
	var password : String;
}

private typedef URL = {
	var name : String;
	var url : String;
}

class Bookmark {
	
	public static var XMLNS = 'storage:bookmarks';
	
	public var conferences : Array<Conference>;
	public var urls : Array<URL>;
	
	public function new() {
		conferences = new Array();
		urls = new Array();
	}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS, 'storage' );
		for( c in conferences ) {
			var e = Xml.createElement( 'conference' );
			e.set( 'jid', c.jid );
			if( c.name != null ) e.set( 'name', c.name );
			if( c.autojoin != null ) e.set( 'autojoin', Std.string( c.autojoin ) );	
			e.addField( c, 'nick' );
			if( c.password != null ) e.addChild( XMLUtil.createElement( 'password', c.password ) );
			x.addChild(e);
		}
		for( u in urls ) {
			var e = Xml.createElement( 'url' );
			e.set( 'name', u.name );
			e.set( 'url', u.url );
			x.addChild(e);
		}
		return x;
	}
	
	public static function parse( x : Xml ) : Bookmark {
		var b = new Bookmark();
		for( e in x.elements() ) {
			switch( e.nodeName ) {
			case 'conference' :
				var conf : Conference = cast { jid : e.get('jid'), name : e.get('name'), nick : e.get('nick') };
				var autojoin = e.get('autojoin');
				if( autojoin != null && autojoin == 'true' ) conf.autojoin = true;
				for( c in e.elements() ) {
					switch( c.nodeName ) {
					case 'nick' : conf.nick = c.firstChild().nodeValue;
					case 'password' : conf.password = c.firstChild().nodeValue;
					}
				}
				b.conferences.push( conf );
			case 'url' :
				b.urls.push( { name : e.get('name'), url : e.get('url') } );
			}
		}
		return b;
	}
	
}
