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

typedef TErrorCondition = {
	var name : String;
	var xmlns : String;
}

/**
	XMPP error extension.
*/
class Error {
	
	public static var XMLNS = "urn:ietf:params:xml:ns:xmpp-stanzas";
	
	public var type : ErrorType;
	public var code : Null<Int>;
	public var name : String;
	public var text : String;
	public var conditions : Array<TErrorCondition>;
	
	public function new( ?type : xmpp.ErrorType,
						 ?code : Null<Int>,
						 ?name : String,
						 ?text : String,
						 ?conditions : Array<TErrorCondition> ) {
		this.type = type;
		this.code = code;
		this.name = name;
		this.text = text;
		conditions = new Array();
	}
	
	public function toXml() : Xml {
		var x = Xml.createElement( "error" );
		if( code != null ) x.set( "code", Std.string( code ) );
		if( type != null ) x.set( "type", Type.enumConstructor( type ) );
		if( name != null ) { //TODO
			var e = Xml.createElement( name );
			//e.set( "xml:lang", "en" );
			e.set( "xmlns", XMLNS );
			if( text != null ) e.addChild( Xml.createPCData( text ) );
			x.addChild( e );
		}
		if( conditions != null ) {
			for( c in conditions )
				x.addChild( XMLUtil.createElement( c.name, c.xmlns ) );
		}
		return x;
	}
	
	public function toString() : String {
		return toXml().toString();
	}
	
	public static function parse( x : Xml ) : xmpp.Error {
		var e = new Error();
		var v = x.get( "code" );
		if( v != null ) e.code = Std.parseInt( v ); 
		v = x.get( "type" );
		if( v != null ) e.type = Type.createEnum( ErrorType, v );
		// TODO  parse Conditions
		for( el in x.elements() ) {
			e.name = el.nodeName;
			try e.text = el.firstChild().nodeValue catch(e:Dynamic){}
			break;
		}
		return e;
	}
	
	/**
-		Parses the error from a given packet.
-	public static function fromPacket( p : xmpp.Packet ) : xmpp.Error {
-		for( e in p.toXml().elementsNamed( "error" ) )
-			return Error.parse( e );
-		return null;
-	}
-	*/

}
