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
	XMPP error extension.
*/
class Error {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-stanzas";
	
	public var type : ErrorType;
	public var code : Int;
	public var name : String;
	public var conditions : Array<{name:String,xmlns:String}>;
	public var text : String;
	
	public function new( ?type : ErrorType, ?code = -1, ?name : String, ?text : String ) {
		this.type = type;
		this.code = code;
		this.name = name;
		this.text = text;
		conditions = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "error" );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		if( code != -1 ) x.set( "code", Std.string( code ) );
		if( name != null ) {
			var n = Xml.createElement( name );
			n.set( "xmlns", XMLNS );
			x.addChild( n );
		}
		for( c in conditions ) {
			
		}
		return x;
	}
	
	public inline function toString() : String {
		return toXml().toString();
	}
	
	/**
		Parses the error from a given packet.
	*/
	public static function fromPacket( p : xmpp.Packet ) : xmpp.Error {
		for( e in p.toXml().elementsNamed( "error" ) )
			return Error.parse( e );
		return null;
	}
	
	/**
		Parses the error from given XML.
	*/
	public static function parse( x : Xml ) : xmpp.Error {
//		if( x.nodeName != "error" ) throw "This is not an error extension";
		var e = new Error( Std.parseInt( x.get( "code" ) ) );
		var et = x.get( "type" );
		if( et != null ) e.type = Type.createEnum( ErrorType, x.get( "type" ) );
		//TODO!!!!!!!!!!!!!! parse Conditions
		var _n = x.elements().next();
		if( _n != null )
			e.name = _n.nodeName;
		return e;
	}
	
}
