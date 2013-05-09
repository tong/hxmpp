/*
 * Copyright (c) 2012, disktree.net
 * 
 * Permission is hereby granted, free of charge, to any person obtaining a copy
 * of this software and associated documentation files (the "Software"), to deal
 * in the Software without restriction, including without limitation the rights
 * to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
 * copies of the Software, and to permit persons to whom the Software is
 * furnished to do so, subject to the following conditions:
 * 
 * The above copyright notice and this permission notice shall be included in
 * all copies or substantial portions of the Software.
 * 
 * THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
 * IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
 * FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
 * AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
 * LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
 * OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
 * THE SOFTWARE.
 */
package xmpp;

/**
	XML utilities.
*/
class XMLUtil {
	
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
		//if( name != null && content != null )
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
			throw 'required field ($n) is missing';
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
		setNamespace( x, ns );
		return ns;
	}
	
	/**
		Hack because flash is unable to set xml namespace (since haxe 2.06) //TODO
	*/
	public static inline function setNamespace( x : Xml, s : String ) {
		#if flash
		x.set( '_xmlns_', s );
		#else
		x.set( 'xmlns', s );
		#end
	}
	
	
}
