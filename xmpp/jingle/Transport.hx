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
package xmpp.jingle;

class Transport {
	
	public static var XMLNS_RAWUDP = "urn:xmpp:jingle:transports:raw-udp:1";
	public static var XMLNS_SOCKS = "urn:xmpp:jingle:transports:s5b:0";
	public static var XMLNS_IBB = "urn:xmpp:jingle:transports:ibb:0";
	
	public var xmlns : String;
	public var attributes : Array<{name:String,value:String}>;
	public var elements : Array<Xml>;

	public function new( xmlns : String) {
		this.xmlns = xmlns;
		attributes = new Array();
		elements = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "transport" );
		x.set( "xmlns", xmlns );
		for( e in attributes ) x.set( e.name, e.value );
		for( e in elements ) x.addChild( e );
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	public static function parse( x : Xml ) : Transport {
		var t = new Transport( x.get( "xmlns" ) );
		for( e in x.elements() ) t.elements.push( e );
		for( a in x.attributes() )
			if( a != "xmlns" )
				t.attributes.push( { name: a, value : x.get( a ) } );
		return t;
	}
	
}
