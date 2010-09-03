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

/**
	Jingle transport candidate.
*/
class Candidate<T> {
	
	public var attributes : T;
	public var elementName : String;
	
	public function new( ?a : T, elementName : String = "candidate" ) {
		this.attributes = a;
		this.elementName = elementName;
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( elementName );
		for( f in Reflect.fields( attributes ) )
			x.set( f, Reflect.field( attributes, f ) );
		return x;
	}
	
	public static function parse<T>( x : Xml ) : T {
		var c : T = cast {};
		for( e in x.attributes() )
			Reflect.setField( c, e, x.get( e ) );
		return c;
	}
	
	public static function parseCandidates<T>( x : Xml, elementName : String = "candidate" ) : Array<T> {
		var c : Array<T> = new Array();
		for( e in x.elementsNamed( elementName ) )
			c.push( Candidate.parse( e ) );
		return c;
	}
	
	//public static function copy<T>( c : Candidate<T> ) : Candidate<T> 
	
}
