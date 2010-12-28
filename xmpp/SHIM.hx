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

private typedef Header = {
	var name : String;
	var value : String;
}

class SHIM {
	
	public static var XMLNS = "http://jabber.org/protocol/shim";
	
	public var headers : Array<Header>;
	
	public function new() {
		headers = new Array();
	}
	
	public function toXml() : Xml {
		var x = IQ.createQueryXml( XMLNS, "headers" );
		for( h in headers ) {
			var e = XMLUtil.createElement( "header", h.value );
			e.set( "name", h.name );
			x.addChild( e );
		}
		return x;
	}
	
	public static function parse( x : Xml ) : xmpp.SHIM {
		var s = new SHIM();
		for( e in x.elementsNamed( "header" ) ) {
			s.headers.push( {
				name : e.get("name"),
				value : e.firstChild().nodeValue
			} );
		}
		return s;
	}
	
}
