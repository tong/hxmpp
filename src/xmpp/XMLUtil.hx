/*
 * Copyright (c) disktree
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
	Utilities and shortcuts for handling XML in context of XMPP
*/
class XMLUtil {
	
	/**
		Create <n>t</n>

		@param n Name of xml element to create
		@param t Node content
	*/
	public static function createElement( n : String, s : String ) : Xml {
		var x = Xml.createElement( n );
		x.addChild( Xml.createPCData( s ) );
		return x;
	}
	
	/**
		Create and add <n>t</n>

		@param x XML element to attach the created element to
		@param n Name of xml node
		@param t Node content
	*/
	public static inline function addElement( x : Xml, n : String, s : String ) : Xml {
		//if( name != null && content != null )
		x.addChild( createElement( n, s ) );
		return x;
	}

	/**
		Reflects/Adds the value of given object field as element to the parent element

		@param x XML element to attach the element to
		@param o The target object, provider of value
		@param n Name of XML node
		@param t Node content
	*/
	public static function addField( x : Xml, o : Dynamic, n : String, ?required : Bool = false ) : Xml {
		var v = Reflect.field( o, n );
		if( v != null )
			addElement( x, n, Std.string(v) );
		else if( required )
			throw 'required field ($n) is missing';
		return x;
	}
	
	/**
		@param x The xml element to attach the created element to
		@param o The target object to retrieve the field values from
		@param f Optional list of reflected field names
	*/
	public static function addFields( x: Xml, o : Dynamic, ?f : Iterable<String> ) : Xml {
		if( f == null ) f = Reflect.fields( o );
		for( e in f ) addField( x, o, e );
		return x;
	}
	
	/**
		TODO use?
	*/
	public static function reflectElements<T>( o : T, x : Xml ) : T {
		for( e in x.elements() )
			Reflect.setField( o, e.nodeName, e.firstChild().nodeValue );
		return o;
	}
	
	/**
		Get (if no ns specified) or set the namespace of the given xml element.

		@param x XML element to attach the create element to
		@param ns Optional namespace to set
	*/
	public static inline function ns( x : Xml, ?s : String ) : String {
		return if( s == null )
			getNamespace( x );
		else {
			setNamespace( x, s );
			s;
		}
	}

	/**
		Returns the namespace attribute ("xmlns") of given element
	*/
	public static inline function getNamespace( x : Xml ) : String {
		return x.get( 'xmlns' );
	}
	
	/**
		Hack because flash is unable to set xml namespace (since haxe 2.06)
	*/
	public static inline function setNamespace( x : Xml, s : String ) : Xml {
		#if flash // TODO flash xml bug
		x.set( '_xmlns_', s );
		#else
		x.set( 'xmlns', s );
		#end
		return x;
	}
	
}
