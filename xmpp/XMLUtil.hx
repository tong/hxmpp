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
	XML extending utilities.
*/
class XMLUtil {
	
	/**
		@param n Name of xml element to create
		@param t Node content
	*/
	public static function createElement( n : String, t : String ) : Xml {
		var x = Xml.createElement( n );
		//TODO required ? if( t != null )
		x.addChild( Xml.createPCData( t ) );
		return x;
	}
	
	/**
		@param x XML element to attach the create element to
		@param n Name of xml node
		@param t Node content
	*/
	public static inline function addElement( x : Xml, n : String, t : String ) : Xml {
		x.addChild( createElement( n, t ) );
		return x;
	}
	
	/**
		@param x XML element to attach the create element to
		@param o The target object to get the field value from
		@param n Name of xml node
		@param t Node content
	*/
	public static function addField( x: Xml, o : Dynamic, n : String, ?required : Bool = false ) : Xml {
		var v = Reflect.field( o, n );
		if( v != null ) addElement( x, n, Std.string(v) );
		else if( required )
			throw "required field "+n+" is missing";
		return x;
	}
	
	/**
		@param x XML element to attach the create element to
		@param o The target object to get the field value from
		@param fields Names of the fields
	*/
	public static function addFields( x: Xml, o : Dynamic, ?fields : Iterable<String> ) : Xml {
		if( fields == null ) fields = Reflect.fields( o );
		for( f in fields ) addField( x, o, f );
		return x;
	}
	
	/**
		Set or get the namespace of the given xml element.
	*/
	public static function ns( x : Xml, ?ns : String ) : String {
		return if( ns == null )
			x.get( 'xmlns' );
		else {
			// TODO haXe 2.06 fukup
			#if flash
			x.set( '_xmlns_', ns );
			#else
			x.set( 'xmlns', ns );
			#end
			null;
		}
	}
	
	/*
	public static function reflectElementValues<T>( x : Xml, o : T ) : T {
		for( e in x.elements() ) {
			
		}
	}
	*/
	
}
