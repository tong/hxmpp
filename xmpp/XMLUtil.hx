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
	Misc XML utilities.
*/
class XMLUtil {
	
	// Misc XML utilities.
	/* Misc XML utilities. */
	static var test : Array<String>;
	static function testit( a : Null<Array<XMLUtil>> ) : String {
		return null;
	}
	
	
	/**
		@param n Name of xml element to create
		@param t Node content
	*/
	public static function createElement( n : String, t : String ) : Xml {
		var x = Xml.createElement( n );
		x.addChild( Xml.createPCData( t ) );
		return x;
	}
	
	/**
		@param x XML element to attach the created element to
		@param n Name of xml node
		@param t Node content
	*/
	public static inline function addElement( x : Xml, name : String, content : String ) : Xml {
		x.addChild( createElement( name, content ) );
		return x;
	}
	
	/**
		@param x XML element to attach the element to
		@param o The target object, provider of value
		@param n Name of XML node
		@param t Node content
	*/
	public static function addField( x : Xml, o : Dynamic, n : String, ?required : Bool = false ) : Xml {
		var v = Reflect.field( o, n );
		if( v != null ) addElement( x, n, Std.string(v) );
		else if( required )
			throw "required field "+n+" is missing";
		return x;
	}
	
	/**
		@param x XML element to attach the created element to
		@param o The target object to retrieve the field values from
		@param fields Optional names of fields, gets reflected if null
	*/
	public static function addFields( x: Xml, o : Dynamic, ?fields : Iterable<String> ) : Xml {
		if( fields == null ) fields = Reflect.fields( o );
		for( f in fields ) addField( x, o, f );
		return x;
	}
	
	/**
		TODO use?
	*/
	public static function reflectElements<T>( target : T, x : Xml ) : T {
		for( e in x.elements() )
			Reflect.setField( target, e.nodeName, e.firstChild().nodeValue );
		return target;
	}
	
	/**
		Get (if no ns specified) or set the namespace of the given xml element.

		@param x XML element to attach the create element to
		@param ns Optional namespace to set
	*/
	public static function ns( x : Xml, ?ns : String ) : String {
		if( ns == null )
			return x.get( 'xmlns' );
		else {
			setNamespace( x, ns );
			return ns;
		}
	}
	
	/**
		Hack because flash is unable to set xml namespace (since haxe 2.06)
	*/
	public static inline function setNamespace( x : Xml, s : String ) {
		#if flash
		x.set( '_xmlns_', s );
		#else
		x.set( 'xmlns', s );
		#end
	}
	
	/*
	public static function setField( x : Xml, n : String, v : String ) : String {
		
	}
	*/
	
	/*
	public static function reflectElementValues<T>( x : Xml, o : T ) : T {
		for( e in x.elements() ) {
			
		}
	}
	*/
	
}
